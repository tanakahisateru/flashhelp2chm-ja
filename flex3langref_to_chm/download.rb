require 'net/http'
require 'set'
require 'fileutils'

if ARGV.length < 4 then
	print "usage:ruby download.rb <host> <remote-base-dir> <start-file> <local-base-dir>\n"
	print " e.g. ruby download.rb livedocs.adobe.com /flex/3_jp/langref index.html langref\n"
	exit(0)
end

host = ARGV[0]
remote_base = ARGV[1]
startfile = ARGV[2]
local_base = ARGV[3]

#host = 'livedocs.adobe.com'
#remote_base = '/flex/3_jp/langref'
#startfile = 'index.html'
#local_base = 'langref'

FCAT_CONTAINER = ['index.html', 'package-frame.html']
FCAT_LIST = ['package-list.html', 'class-list.html', 'all-classes.html', 'index-list.html', 'mxml-tags.html']
def valid_page?(html, url)
    filename = url.split('/')[-1]
    if FCAT_CONTAINER.include?(filename) then
        if html =~ /<frameset/i and html =~ /Flex/i then
            return true
        end
    elsif FCAT_LIST.include?(filename) then
        if html =~ /<body\s+class=\"classFrameContent\">/i then
            return true
        end
    else
        if html =~ /Flex/i and html =~ /<div\s+class=\"MainContent\">/i then
            return true
        end
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
				print "  link to : %s\n" % found
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
MAX_RETRY = 1
retry_count = 0
while not task.empty?
	url = task.shift()
	
	if error_urls.include?(url) then
		next
	end
	
    print url + " : "
    STDOUT.flush()
    
	if File.exist?(local_base + '/' + url) then
		print "SKIP (%d/%d)\n" % [1 + cmpl.size, 1 + task.size + cmpl.size]
		open(local_base + '/' + url, 'rb') { |fd|
			body = fd.read()
			findlink(body, url, task, cmpl)
		}
		cmpl.push(url)
		next
	end
	
    resp = nil
	Net::HTTP.start(host) { |http|
		resp = http.get(remote_base + '/' + url)
	}
    if resp.code == "200" then
        #livedocs.adobe.com has a critical bug, it respond incorrect content sometimes...
        if url =~ /\.html?$/ and not valid_page?(resp.body, url) then
            print "INVALID(%d/%d)\n" % [retry_count+1, MAX_RETRY]
            retry_count+=1
            if retry_count < MAX_RETRY then
                task.unshift(url)
                sleep(3)  #retry after 3sec
                next
            else
                print "-- moved to the end of queue.\n"
                task.push(url)
                retry_count = 0
                next
            end
        end
        retry_count = 0;
        print "OK(%d/%d)\n" % [1 + cmpl.size, 1 + task.size + cmpl.size]
        dir = local_base + '/' + url.split('/')[0...-1].join('/')
        FileUtils.mkdir_p(dir) if not File.exist?(dir)
        open(local_base + '/' + url, 'wb') { |fd|
            fd.write(resp.body)
        }
        findlink(resp.body, url, task, cmpl)
    else
        print "ERROR %d (%d/%d)\n" % [resp.code, 1 + cmpl.size, 1 + task.size + cmpl.size]
        error_urls.push(url)
        open('error_urls.log', 'a') { |fd|
            fd.puts(url)
        }
    end
    sleep(0.2)  #retry after 3sec
	cmpl.push(url)
end
