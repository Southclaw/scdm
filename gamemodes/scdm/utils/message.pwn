#include <YSI\y_va>

static stock gs_Buffer[256];

stock va_formatex(output[], size = sizeof(output), const fmat[], va_:STATIC_ARGS)
{
	new
		num_args,
		arg_start,
		arg_end;
	
	// Get the pointer to the number of arguments to the last function.
	#emit LOAD.S.pri 0
	#emit ADD.C 8
	#emit MOVE.alt
	// Get the number of arguments.
	#emit LOAD.I
	#emit STOR.S.pri num_args
	// Get the variable arguments (end).
	#emit ADD
	#emit STOR.S.pri arg_end
	// Get the variable arguments (start).
	#emit LOAD.S.pri STATIC_ARGS
	#emit SMUL.C 4
	#emit ADD
	#emit STOR.S.pri arg_start
	// Using an assembly loop here screwed the code up as the labels added some
	// odd stack/frame manipulation code...
	while (arg_end != arg_start)
	{
		#emit MOVE.pri
		#emit LOAD.I
		#emit PUSH.pri
		#emit CONST.pri 4
		#emit SUB.alt
		#emit STOR.S.pri arg_end
	}
	// Push the additional parameters.
	#emit PUSH.S fmat
	#emit PUSH.S size
	#emit PUSH.S output
	// Push the argument count.
	#emit LOAD.S.pri num_args
	#emit ADD.C 12
	#emit LOAD.S.alt STATIC_ARGS
	#emit XCHG
	#emit SMUL.C 4
	#emit SUB.alt
	#emit PUSH.pri
	#emit MOVE.alt
	// Push the return address.
	#emit LCTRL 6
	#emit ADD.C 28
	#emit PUSH.pri
	// Call formatex
	#emit CONST.pri formatex
	#emit SCTRL 6
}

stock msg_SendClientMessage(playerid, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new i = 128; i > 0; i--)
		{
			if(string[i] == ' ' || string[i] ==  ',' || string[i] ==  '.')
			{
				splitpos = i;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, string);
		SendClientMessage(playerid, colour, string2);
	}
	else
	{
		SendClientMessage(playerid, colour, string);
	}

	return 1;
}
#if defined _ALS_SendClientMessage
    #undef SendClientMessage
#else
    #define _ALS_SendClientMessage
#endif
#define SendClientMessage msg_SendClientMessage

stock msg_SendClientMessageToAll(colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new i = 128; i>0; i--)
		{
			if(string[i] == ' ' || string[i] ==  ',' || string[i] ==  '.')
			{
				splitpos = i;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		SendClientMessageToAll(colour, string);
		SendClientMessageToAll(colour, string2);
	}
	else SendClientMessageToAll(colour, string);

	return 1;
}
#if defined _ALS_SendClientMessageToAll
    #undef SendClientMessageToAll
#else
    #define _ALS_SendClientMessageToAll
#endif
#define SendClientMessageToAll msg_SendClientMessageToAll


stock SendClientMessageF(playerid, colour, fmat[], va_args<>)
{
	va_formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	SendClientMessage(playerid, colour, gs_Buffer);

	return 1;
}

stock SendClientMessageToAllF(colour, fmat[], va_args<>)
{
	va_formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<2>);
	SendClientMessageToAll(colour, gs_Buffer);

	return 1;
}

stock SendClientMessageToAdminsF(level, colour, fmat[], va_args<>)
{
	va_formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	SendClientMessageToAdmins(level, colour, gs_Buffer);

	return 1;
}
