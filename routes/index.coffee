fs = require('fs')
util = require('util')

exec = require('child_process').exec
decodeCode=(asm,code)->
	#split input
	asm_lines = asm.split("\n")
	code_lines = code.split("\n")
	labels={}
	label_data={}
	currentlabel=null
	files=[]
	readmode=false
	currentline=0
	for asline in asm_lines

		linedata=/^[ ]+[0-9]+ (.*)/m.exec(asline)
		if linedata?
			#parse file start markers '.file "filename"'
			file=/^[ \t]*\.file[ \t]+([0-9]*)?[ ]?\"([^"]*)"/m.exec(linedata[1])
			if file?
				fid=if file[1] then file[1] else 0

				fname=file[2]
				files[parseInt(fid)]= /(^test|\/test)/.test(fname)
				readmode=files[parseInt(fid)]
				currentline=0
			else
				#scan for labels
				label=/\.([^ :]*):/m.exec(linedata[1])
				if label?
					if labels[label[1]]?
						labels[label[1]]++
					else
						if currentlabel? and currentlabel < 1
							delete label_data[currentlabel]

						labels[label[1]]= 0
						label_data[label[1]]= {0:linedata[1]+"\n"}
						currentlabel=label[1]
				else if currentlabel?
					#parse .loc
					loc= /^[ \t]*.loc ([0-9]+) ([0-9]+)/.exec(linedata[1])
					if loc?
						readmode=files[parseInt(loc[1])]
						currentline=if readmode then parseInt(loc[2]) else 0
					else
						if not label_data[currentlabel][currentline]?
							label_data[currentlabel][currentline]=""
						label_data[currentlabel][currentline]+= linedata[1]+"\n"
						if readmode
							labels[currentlabel]++
	if currentlabel? and currentlabel < 1
		delete label_data[currentlabel]
	{code:code_lines,asm:label_data}


exports.error404 = (req, res)->
  res.status(404)
  res.render('404', { title: 'C/C++ to Assembly' })

exports.indexpost = (req, res)->
	optimize=if req.body.optimize? then "-O2" else ""
	lang=if req.body.language=="c" then "c" else "cpp"
	#Generate file name
	fileid=Math.floor(Math.random()*1000000001)
	compiler=if req.body.arm then "arm-linux-gnueabi-g++-4.6" else "gcc"
	asm=if req.body.intel_asm then "-masm=intel" else ""

	#Write input to file
	fs.writeFile "/tmp/test#{fileid}.#{lang}", req.body.ccode, (err)->
		if err
			res.json({error:"Server Error"})
		else
			# Execute GCC
			compilecmd = "c-preload/compiler-wrapper #{compiler} #{asm} " +
										"-std=c99 -c #{optimize} -Wa,-ald " +
										"-g /tmp/test#{fileid}.#{lang}"
			exec compilecmd,
					{timeout:10000,maxBuffer: 1024 * 1024*10},
					(error, stdout, stderr)->
					if error?
						#Send error message to the client
						res.json({error:error.toString()})
						fs.unlink("/tmp/test#{fileid}.#{lang}")
						fs.unlink("test#{fileid}.o")
					else
						#Parse standart output
						blocks=decodeCode(stdout,req.body.ccode)
						#Send result as json to the clien
						res.json(blocks)
						#Clean up
						fs.unlink("/tmp/test#{fileid}.#{lang}")
						fs.unlink("test#{fileid}.o")
