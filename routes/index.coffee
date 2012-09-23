fs = require('fs')
util = require('util');

exec = require('child_process').exec;
decodeCode=(data)->
	#split input
	assembly_code = data.split("\n")
	infile=false
	scanning_code=false
	stated=false
	start=0
	end=0
	stated2=false
	start2=0
	end2=1
	blocks=[]
	mapping=[]
	current_block=""
	current_assembly_block=""
	mapping=[]
	finalmapping={}
	maxline=-1
	#process each line
	for line in assembly_code
		#parse file start markers '.file "filename"'
		filematch=/^[ ]*([0-9]*)[\t ]*\.file[^"]*"(.*)"/m.exec(line)
		if filematch?
			#ignore header files
			if filematch[2].indexOf(".h") == -1
				#set in file flag if the file name contains the word "test"
				infile=filematch[2].indexOf("test") != -1

		else if infile
			#parse C/C++ code line in testfile e.g. "71:test.cpp      **** 							if(it->first > w) {"
			match=/^[ ]+([0-9]*)[:][^ ]*(test)[^ ]* [*]* (.*)/m.exec(line)
			if match?
				#Code scaning block has changed from assembly to C/C++ code -> store last block
				if not scanning_code
					mapping.push 
						code_start:start
						code_end:end
						assembly_start:start2
						assembly_end:end2
					blocks.push
						code_part:if current_block=="" then "" else start+"_"+end
						code_start:start
						code_end:end
						code:current_block
						assembly_part:start2+"_"+end2
						assembly:current_assembly_block
					#rest scanner
					current_block=""
					current_assembly_block=""
					scanning_code=true
					started=false
					started2=false
				#Parse line nr
				lid=parseInt(match[1])
				#set block start line if not set
				if not started
					start=lid
					started=true
				#set block end line
				end=lid
				#Only add lines which where not scanned yet. 
				# A line of C/C++ code can be translated in to multiple non contiguous assembly code blocks
				if lid>maxline
					maxline=lid
					current_block+=match[3]+"\n"
			else #Is Assembly code
				#parse general C/C++ code line
				matchc=/^[ ]+([0-9]*)[:](.*)/m.exec(line)
				#parse assembly line " 436 03dd 837DE400 		cmpl	$0, -28(%rbp)"
				match2=/^[ ]+([0-9]*) (.*)/m.exec(line)

				#is assembly code
				if match2? and not matchc?
					lid=parseInt(match2[1])
					#set block start line if not set
					if not started2
						start2=lid
						started2=true
					#set block end line
					end2=lid
					#add line to assembly code block
					current_assembly_block+=match2[2]+"\n"
					scanning_code=false
	#Add last code Block
	blocks.push
		code_part:if current_block=="" then "" else start+"_"+end
		code_start:start
		code_end:end
		code:current_block
		assembly_part:start2+"_"+end2
		assembly:current_assembly_block
	mapping.push
		code_start:start
		code_end:end
		assembly_start:start2
		assembly_end:end2
	#Group mapping by code block
	for map in mapping
		for block in blocks
			if block.code_part!="" and ((map.code_start>=block.code_start and map.code_start<=block.code_end) or (map.code_start<=block.code_start and map.code_end>=block.code_end) or (map.code_end>=block.code_start and map.code_end<=block.code_end))
				if not finalmapping[block.code_part]?
					finalmapping[block.code_part]=[]
				finalmapping[block.code_part].push map.assembly_start+"_"+map.assembly_end
 	#Return data to client
	{data:blocks,mapping:finalmapping}


exports.error404 = (req, res)->
  res.status(404)
  res.render('404', { title: 'C/C++ to Assembly' });

exports.indexpost = (req, res)->
	optimize=if req.body.optimize? then "-O2" else ""
	lang=if req.body.language=="c" then "c" else "cpp"
	#Generate file name
	fileid=Math.floor(Math.random()*1000000001);
	compiler=if req.body.arm then "arm-linux-gnueabi-g++-4.6" else "gcc"
	
	#Write input to file
	fs.writeFile "/tmp/test#{fileid}.#{lang}", req.body.ccode, (err)->
		if err
			res.json({error:"Server Error"});
		else
			# Execute GCC
			exec "c-preload/compiler-wrapper #{compiler} -c #{optimize} -Wa,-ahldn  -g /tmp/test#{fileid}.#{lang}", {timeout:10000,maxBuffer: 1024 * 1024*10}, (error, stdout, stderr)->
					if error?
						#Send error message to the client
						res.json({error:error.toString()});
						fs.unlink("/tmp/test#{fileid}.#{lang}")
						fs.unlink("test#{fileid}.o")
					else
						#Parse standart output
						blocks=decodeCode(stdout)
						#Send result as json to the clien 
						res.json(blocks);
						#Clean up
						fs.unlink("/tmp/test#{fileid}.#{lang}")
						fs.unlink("test#{fileid}.o")




