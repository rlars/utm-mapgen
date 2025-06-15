## Convert xyz and geotiff files with Julia
# start with -t<n> to have multiple threads available
# You need a modified version of TiffImages which can decode the black-and-white images from https://github.com/rlars/TiffImages.jl!
#
# Instructions:
# - Download and pre-parse the height maps with `bulk_download`.
# - Somehow retrieve the dtk25 maps.
# - Use `convert_maps` to create the data used in this mod.

using ZipFile
using FileIO
using Downloads


# download multiple data files and apply file_action in-memory
# Example usage:
# dns = "dgm1_32_" .* string.(459 .+ (0:2:2)) .* "_" .* (string.(5402 .+ (0:2:2)))' .* "_2_bw"
# bulk_download(raw"https://opengeodata.lgl-bw.de/data/dgm/", dns, ".zip", contains(r"dgm1.*.xyz"), (filename, file) -> handlexyz(filename, file, raw"C:\your\output_dir"))
# bulk_download(raw"https://opengeodata.lgl-bw.de/data/dom1/", dns, ".zip", contains(r"dom1.*.tif"), (filename, file) -> handleheighttiff(filename, file, raw"C:\your\output_dir"))
function bulk_download(baseurl::String, name_iterator, suffix::String, filename_filter, file_action)
	num_threads = 8
	tasks = Vector{Union{Nothing, Task}}(nothing, num_threads)
	buffers = [IOBuffer() for i in 1:num_threads]
	downloader = Downloads.Downloader()
	for name in name_iterator
		remove_completed!(tasks)
		while (i = findnext(isnothing, tasks, 1)) == nothing
			sleep(0.1)
			remove_completed!(tasks)
		end
		seekstart(buffers[i])
		truncate(buffers[i], 0)
		url = baseurl * name * suffix
		Downloads.download(url, buffers[i]; downloader = downloader)
		tasks[i] = Threads.@spawn begin
			process_zip_in_memory(buffers[i], filename_filter, file_action)
			println("Downloaded " * $name)
		end
	end
	
	while any(!isnothing, tasks)
		sleep(0.1)
		remove_completed!(tasks)
	end
end

# convert downloaded data to the format expected by the utm_mapgen mod
# example: convert_maps(raw"C:\downloaded\files", raw"C:\luanti\mods\utm_mapgen\geodata", CartesianIndices((450:10:489, 5400:10:5439)) )
function convert_maps(input_dir::String, output_dir::String, indices::CartesianIndices)
	# landcover
	Threads.@threads for (gridx, gridy) in Tuple.(indices)
		final_cats = createcoarsecategories(input_dir, gridx, gridy)
		
		write(output_dir * "usage" * "_32_$(gridx)_$(gridy).bin", UInt16.(
			   256 * final_cats["weis"] +
			   4 * max.(final_cats["stge"], final_cats["stor"], UInt8.(final_cats["weis"] .> 0)) +
			   max.(final_cats["wald"], 2 * final_cats["sebl"], 2 * final_cats["babl"], 8 * UInt8.(final_cats["haus"] .> 0), final_cats["haus"])))
	end

	# ground height
	Threads.@threads for (gridx, gridy) in Tuple.(indices)
		dgms = createcoarse(input_dir, gridx, gridy, :dgm)
		write(output_dir * "height_dgm" * "_32_$(gridx)_$(gridy).bin", round.(UInt8, dgms/10))
	end

	# measured height (including trees, buildings etc.)
	Threads.@threads for (gridx, gridy) in Tuple.(indices)
		data = createcoarse(input_dir, gridx, gridy, :dom)
		write(output_dir * "height_dom" * "_32_$(gridx)_$(gridy).bin", round.(UInt8, data/10))
	end
end

function remove_completed!(tasks::Vector{Union{Nothing, Task}})
	findall(x -> !isnothing(x) && istaskdone(x), tasks) .|> i -> begin fetch(tasks[i]); tasks[i] = nothing end
end

function process_zip_in_memory(io::Union{AbstractString, IO}, filename_filter, file_action)
	zarchive = ZipFile.Reader(io)
	ret = map(zarchive.files) do f
		if filename_filter(f.name)
			println("Reading ", f.name)
			name = last(split(f.name, "/"))
			file_action(name, f)
		end
	end
	# workaround to prevent ZipFile.Reader from being gc'ed, see https://github.com/fhs/ZipFile.jl/issues/14
	close(zarchive)
	#return ret
end

# parse and save an xyz file
function handlexyz(name::String, f, output_dir::String)
	conv = parsexyz(f, (1001, 1001))
	write(joinpath(output_dir, name * ".bin"), round.(UInt16, 16*conv))
end

# parse and save a tiff file
function handleheighttiff(name::String, f, output_dir::String)
	stream = FileIO.Stream{format"TIFF"}(IOBuffer(read(f)))
	img = TiffImages.load(read(stream, TiffFile))
	data = img.data
	if data isa Vector{Matrix{TiffImages.ColorTypes.Gray{Float32}}}
		# some tiffs contain two resolutions
		data = data[1]
	end
	# convert data to align the right-then-up orientation
	data = data[end:-1:1,:]'
	write(joinpath(output_dir, name * ".bin"), round.(UInt16, max.(0, 16*reinterpret(Float32, data))))
end

Base.adjoint(x::String) = x

# mostly copy of function Base.read(io::Stream, ::Type{TiffFile}) in files.jl
# but with filepath replaced by ""
function Base.read(io::Stream{DataFormat{:TIFF}, IOBuffer, Nothing}, ::Type{TiffFile})
    seekstart(io)
    filepath = ""
    bs = TiffImages.need_bswap(io)
    offset_size = TiffImages.offsetsize(io)
    first_offset_raw = read(io, offset_size)
    first_offset = Int(bs ? _bswap(first_offset_raw) : first_offset_raw)
    TiffFile{offset_size, typeof(io)}(nothing, filepath, io, first_offset, bs)
end


function convert_filename(name::AbstractString, prefix::String, suffix::String)
	m = match(Regex(prefix * raw"_?(?<x>[0-9]*)_(?<y>[0-9]*)_" * suffix), name)
	if (isnothing(m)) error("Name does not match: ", name) end
	return parse.(Int, (m["x"], m["y"]))
end

function calc_sum(matrix::Matrix{T}, new_size::Tuple{Int64,Int64}) where {T<:Number}
    reduced_matrix = zeros(widen(T), new_size)
	factors = Int64.(size(matrix)./new_size)

    for i in 1:new_size[1]
        for j in 1:new_size[2]
            reduced_matrix[i, j] = sum(matrix[(factors[1]*i-factors[1]+1):(factors[1]*i), (factors[2]*j-factors[2]+1):(factors[2]*j)])
        end
    end

    return reduced_matrix
end

# simple and untested float parser magnitudes faster than what is available by default
function fastparseFloat32(v::AbstractString)
	out = 0
	i = length(v)
	while i > 0
		if v[i] == '.'
			i = i - 1
			break
		end
		out = 0.1 * out + (UInt8(v[i]) - UInt8('0'))
		i = i - 1
	end
	m = 1
	out *= 0.1
	while i > 0
		out = out + m * (UInt8(v[i]) - UInt8('0'))
		m = 10 * m
		i = i - 1
	end
	return out
end

# parse the xyz file, assuming it is ordered
# return a matrix which has the same order (column-first!)
function parsexyz(file, size::Tuple{Int, Int})
	file_content = read(file, String)
	println("Contents: ", length(file_content))
	vals = zeros(Float32, size[1]*size[2])
	buf = IOBuffer(file_content)
	i = 1
	for line in eachline(buf)
		if !isempty(line)
			#vals[i] = parse(Float32, split(line, ' ')[3])
			vals[i] = fastparseFloat32(@view line[findlast(' ', line) + 1:end])
			i = i + 1
		end
	end
	println("Parsed lines: ", length(vals))
	return reshape(vals, size)
end

# concatenate matrices in a way useful for images
function mergematrices(matrices::AbstractVector{Pair{Tuple{Int, Int}, Matrix{UInt8}}}, stepsize::Int)
	mkeys = first.(matrices)
	lens = size(matrices[1].second)
	xs = minimum([x for (x, y) in mkeys]):stepsize:maximum([x for (x, y) in mkeys])
	ys = minimum([y for (x, y) in mkeys]):stepsize:maximum([y for (x, y) in mkeys])
	ret = zeros(UInt8, (length(ys) * lens[1], length(xs) * lens[2]))
	matrices .|> m -> begin
		x = only(indexin(m.first[1], xs)) - 1
		y = length(ys) - only(indexin(m.first[2], ys))
		ret[lens[1]*y + 1:lens[1]*(y+1), lens[2]*x + 1:lens[2]*(x+1)] .= m.second
	end
	return ret
end


### assemble 10x10 km squares from 1x1 km squares (height)
# example: createcoarse(raw"C:\folder\with\1mx1m_data", 470, 5410)
function createcoarse(dir::String, x::Int, y::Int, mode::Symbol)
	data = zeros(Float32, (50*10, 50*10))
	filenames = readdir(dir, join=true)
	for ix in x:x+9
		for iy in y:y+9
			if mode == :dom
				regex = Regex(".*dom1_32_$(ix)_$(iy).*.bin")
			elseif mode == :dgm
				regex = Regex(".*dgm1_32_$(ix)_$(iy).*.bin")
			else
				error("Unknown mode $mode")
			end
			
			filename = filter(contains(regex), filenames)
			if isempty(filename)
				@warn "Filename could not be found" regex
				continue
			end
			
			filename = only(filename)
			input = reinterpret(UInt16, read(filename))
			if length(input) == 1000000
				input = reshape(input, (1000, 1000))
			elseif length(input) == 1002001
				input = reshape(input, (1001, 1001))
			else
				error("Unsupported input size")
			end
			data[(50*ix+1:50*(ix+1)) .- 50*x, (50*iy+1:50*(iy+1)) .- 50*y] = calc_sum(input[1:1000,1:1000], (50, 50))/(16*400) # data is stored with precision of 1/16 m
		end
	end
	return data
end

# categories are suffixes in dtk map folder
# wald - forrest
# weis - mostly small roads, but also few points of interest
# haus - house
# stor - orange street (highway)
# stge - yellow roads
# sebl - blue rivers and lakes
# babl - light-blue rivers and lakes
# acke - agricultural areas
# rohs - red marked houses (public buildings mostly)
area_categories = ["wald", "weis", "haus", "stor", "stge", "sebl", "babl", "acke"] # TODO: "rohs"

### assemble 10x10 km squares from 5x5 km squares (landcover)
function createcoarsecategories(dir::String, x::Int, y::Int)
	data = Dict(map(area_categories) do x x => zeros(UInt8, (500, 500)) end )
	filenames = readdir(dir, join=true)
	for ix in x:5:x+9
		for iy in y:5:y+9
			regex = Regex(".*dtk25_32$(ix)_$(iy)_5_bw.zip")
			zipname = only(filter(contains(regex), filenames))
			
			process_zip_in_memory(zipname, filename -> endswith(filename, "tif") && any(area_categories .|> occursin(filename)), (filename, file) -> begin
				cat = only(area_categories |> filter(occursin(filename)))
				stream = FileIO.Stream{format"TIFF"}(IOBuffer(read(file)))
				img = TiffImages.load(read(stream, TiffFile))
				
				_data = nothing
				if cat == "weis" || cat == "haus"
					quarters = UInt8.(calc_sum(Int.(img.data), (500, 500)) .< thresh / 4)
					_data = quarters[1:2:end, 1:2:end] .<< 4 + quarters[1:2:end, 2:2:end] .<< 5 + quarters[2:2:end, 1:2:end] .<< 6 + quarters[2:2:end, 2:2:end] .<< 7
				else
					_data = UInt8.(calc_sum(Int.(img.data), (250, 250)) .< thresh)
				end
				data[cat][(50*ix+1:50*(ix+5)) .- 50*x, (50*iy+1:50*(iy+5)) .- 50*y] = _data[end:-1:1, :]'
			end)
		end
	end
	return data
end


### create 1x1 km squares from 5x5 km squares (landcover)
### requires dtk10 files!
function createfinecategories(input_dir::String, output_dir::String, x::Int, y::Int)
	data = zeros(UInt8, (5000, 5000))
	filenames = readdir(dir, join=true)
	regex = Regex(".*dtk10_32$(x)_$(y)_5_bw.zip")
	zipname = only(filter(contains(regex), filenames))
	cat_weight = Dict(["weis" => 4, "haus" => 8, "stor" => 4, "stge" => 4, "sebl" => 2, "acke" => 1, "rohs" => 8])
	categories = [x.first for x in cat_weight]
	process_zip_in_memory(zipname, filename -> endswith(filename, "tif") && any(categories .|> occursin(filename)), (filename, file) -> begin
		cat = only(categories |> filter(occursin(filename)))
		stream = FileIO.Stream{format"TIFF"}(IOBuffer(read(file)))
		img = TiffImages.load(read(stream, TiffFile))
		
		data = max.(data, cat_weight[cat] * (1 .- reinterpret(UInt8, img.data)[1:2:end, 1:2:end]))
	end)
	data = UInt8.(data[end:-1:1, :]')
	
	for (gridx, gridy) in Tuple.(CartesianIndices((0:4, 0:4)))
		write(joinpath(output_dir, landcover_32" * "$(x + gridx)_$(y + gridy).bin"), data[1000*gridx + 1:1000*(gridx + 1), 1000*gridy + 1:1000*(gridy + 1)])
	end
end


# inverse threshold of pixels of a given category
thresh = div(4000, 250)^2 * 0.7

function encode_quarters(tiffs, category)
	quarters = mergematrices(
		map(tiffs) do tiff
			data = tiff.second |> filter(((k, v),) -> k == category) |> only |> ((k, v),) -> v.data
			return tiff.first => UInt8.(calc_sum(Int.(data), (500, 500)) .< thresh / 4)
		end,
		5)
	return quarters[1:2:end, 1:2:end] .<< 4 + quarters[1:2:end, 2:2:end] .<< 5 + quarters[2:2:end, 1:2:end] .<< 6 + quarters[2:2:end, 2:2:end] .<< 7
end
