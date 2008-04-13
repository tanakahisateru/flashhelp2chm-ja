require 'fileutils'

def scandir base, path
	Dir.foreach(File.join(base, path)) do |file|
		relfile = path + "/" + file
		if File.ftype(File.join(base, relfile)) == "directory" then
			if file == "examples" then
				yield(relfile)
			else
				scandir(base, relfile){|f2| yield(f2)} unless file =~ /^\./
			end
		end
	end
end

fromDir = ARGV[0]
toDir   = ARGV[1]
scandir(fromDir, "") do |exdir|
	print exdir + "\n"
	fromExDir = File.join(fromDir, exdir)
	toExDir = File.join(toDir, exdir)
	FileUtils.mkdir(toExDir) if not File.exist?(toExDir)
	Dir.foreach(fromExDir) do |file|
		#p File.join(fromExDir, file)
		if File.ftype(File.join(fromExDir, file)) == 'file' then 
			FileUtils.cp(File.join(fromExDir, file), toExDir)
		end
	end
end
