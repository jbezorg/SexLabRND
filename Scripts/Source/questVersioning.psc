Scriptname questVersioning extends Quest

int Property qvCurrentVersion Auto Hidden 

int Function qvGetVersion()
	Debug.Trace("================================================================================")
	Debug.Trace("= WARNING: You must define the function 'qvGetVersion' within you quest script =")
	Debug.Trace("================================================================================")
	return -1
endFunction

function qvUpdate( int aiCurrentVersion )
	Debug.Trace("================================================================================")
	Debug.Trace("= WARNING: You must define the function 'qvUpdate' within you quest script     =")
	Debug.Trace("================================================================================")
endFunction
