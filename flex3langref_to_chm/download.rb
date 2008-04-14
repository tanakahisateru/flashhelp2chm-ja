require 'net/http'
require 'set'
require 'fileutils'

host = ARGV[0]
remote_base = ARGV[1]
local_base = ARGV[2]

host = 'livedocs.adobe.com'
remote_base = '/flex/3_jp/langref'
startfile = 'index.html'
local_base = 'langref'

def valid_page?(html)
	if html =~ /\WFlex\W/ then
		return true
	else
		return false
	end
end

def pathjoin(dir, rel)
	dir_a = dir.split('/')
	rel_a = rel.split('/')
	while rel_a[0] == '..' || rel_a[0] == '.' do
		if rel_a[0] == '..' then
			dir_a.pop()
		end
		rel_a.shift()
	end
	return (dir_a + rel_a).join('/')
end

def dir_of(path)
	return path.split('/')[0...-1].join('/')
end

def scan_content(html, url, re, place, task, cmpl)
	html.scan(re) { |hit|
		dir = dir_of(url)
		rel = hit[place]
		rel.gsub!(/(\w+)\.\//, $1+"/")  #avoid document bug : "rpc./class-"
		found = pathjoin(dir, rel)
		if not(task.include?(found) || cmpl.include?(found)) then
			if not rel =~ /^\// then
				print "found : %s\n" % found
				yield found
			end
		end
	}
end

def findlink(html, url, task, cmpl)
	if url =~ /\.html?$/ then
		re = /(src|href)=\"([^\"\'\?\#\:]+)\"/
		scan_content(html, url, re, 1, task, cmpl) {|found|
			task.push(found)
		}
		re = /loadClassListFrame\([\'\"]([^\"\'\?\#\:]+)[\'\"]\)/
		scan_content(html, url, re, 0, task, cmpl) {|found|
			task.push(found)
		}
		re = /\"src\", \"(examples\/.+?)\"/
		scan_content(html, url, re, 0, task, cmpl) {|found|
			task.push(found + ".swf")
		}
	elsif url =~ /\.css$/ then
		re = /url\((.+?)\)/
		scan_content(html, url, re, 0, task, cmpl) {|found|
			task.push(found)
		}
	else
		return
	end
end

task = [startfile]
cmpl = []

error_urls = []
if File.exist?('error_urls.log') then
	IO.foreach('error_urls.log', 'r') { |line|
		error_urls.push(line)
	}
end

while not task.empty?
	url = task.shift()
	
	if error_urls.include?(url) then
		next
	end
	
	if File.exist?(local_base + '/' + url) then
		print "SKIP : %s (%d/%d)\n" % [url, 1 + cmpl.size, 1 + task.size + cmpl.size]
		open(local_base + '/' + url, 'rb') { |fd|
			body = fd.read()
			findlink(body, url, task, cmpl)
		}
		cmpl.push(url)
		next
	end
	
	Net::HTTP.start(host) { |http|
		resp = http.get(remote_base + '/' + url)
		if resp.code == "200" then
			if url =~ /\.html?$/ and not valid_page?(resp.body) then
				print "INVALID PAGE (livedocs bug) : %s\n" % url
				task.unshift(url)
				next
			end
			print "OK : %s (%d/%d)\n" % [url, 1 + cmpl.size, 1 + task.size + cmpl.size]
			dir = local_base + '/' + url.split('/')[0...-1].join('/')
			FileUtils.mkdir_p(dir) if not File.exist?(dir)
			open(local_base + '/' + url, 'wb') { |fd|
				fd.write(resp.body)
			}
			findlink(resp.body, url, task, cmpl)
		else
			print "ERROR : %s (%d/%d)\n" % [url, 1 + cmpl.size, 1 + task.size + cmpl.size]
			error_urls.push(url)
			open('error_urls.log', 'a') { |fd|
				fd.puts(url)
			}
		end
	}
	cmpl.push(url)
end
