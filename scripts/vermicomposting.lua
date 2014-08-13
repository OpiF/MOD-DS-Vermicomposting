function vcReload()
	package.loaded['vermicomposting'] = nil
	require ("vermicomposting")
end

function printMessage() 
	print "new message"
end

printMessage()