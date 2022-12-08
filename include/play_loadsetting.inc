#if defined _play_loadsetting_included
  #endinput
#endif
#define _play_loadsetting_included

// Criado por Satelite

public LoadSettingStringArray( const filename[], const setting_section[], setting_key[], Array:array_handle ){
	if( strlen( filename ) < 1 )
		return false;

	if( strlen( setting_section ) < 1 || strlen( setting_key ) < 1 )
		return false;
	
	if( array_handle == Invalid_Array )
		return false;
	
	new path[ 64 ];
	get_configsdir( path, charsmax( path ))
	format( path, charsmax( path ), "%s/%s", path, filename );
	
	if( !file_exists( path ))
		return false;
	
	new file = fopen( path, "rt");
	if( !file )
		return false;
	
	new linedata[ 1024 ]
	
	new section[ 64 ];
	while( !feof( file )){
		fgets( file, linedata, charsmax( linedata ))
		replace( linedata, charsmax( linedata ), "^n", "");
		
		if( linedata[ 0 ] == '['){
			copyc( section, charsmax( section ), linedata[ 1 ], ']')
		
			if( equal( section, setting_section ))
				break;
		}
	}
	
	if( !equal( section, setting_section )){
		fclose( file );
		return false;
	}
	
	new key[ 64 ], values[ 1024 ], current_value[ 128 ];
	while( !feof( file )){
		fgets( file, linedata, charsmax( linedata ))
		replace( linedata, charsmax( linedata ), "^n", "")
		
		if( !linedata[ 0 ] || linedata[ 0 ] == ';')
			continue;
		
		if( linedata[ 0 ] == '[')
			break;
		
		strtok( linedata, key, charsmax( key ), values, charsmax( values ), '=')
		
		trim(key)
		trim(values)
		
		if( equal( key, setting_key )){
			while( values[ 0 ] != 0 && strtok( values, current_value, charsmax( current_value ), values, charsmax( values ), ',')){
				trim( current_value );
				trim( values );
				ArrayPushString( array_handle, current_value );
			}
			
			fclose( file );
			return true;
		}
	}
	
	fclose( file );
	return false;
}

public LoadSettingFloat(const filename[], const setting_section[], setting_key[], Array:array_handle ){
	if (strlen(filename) < 1){
		//jail_log( LOG_ERROR, "Nao e possivel carregar as configuracoes: play_jailbreak.ini")
		return false;
	}
	
	if (strlen(setting_section) < 1 || strlen(setting_key) < 1){
		//jail_log( LOG_ERROR, "Nao e possivel carregar as configuracoes: empty section/key")
		return false;
	}
	
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, filename)
	
	if (!file_exists(path))
		return false;
	
	new file = fopen(path, "rt")
	if (!file)
		return false;
	
	new linedata[1024], section[64]
	while (!feof(file)){
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")

		if (linedata[0] == '['){
			copyc(section, charsmax(section), linedata[1], ']')
			
			if (equal(section, setting_section))
				break;
		}
	}
	
	if (!equal(section, setting_section)){
		fclose(file)
		return false;
	}
	
	new key[64], values[ 1024 ]
	while (!feof(file)){
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
	
		if (!linedata[0] || linedata[0] == ';')
			continue;
		
		if (linedata[0] == '[')
			break;
		
		strtok( linedata, key, charsmax( key ), values, charsmax( values ), '=')
		
		trim(key)
		trim(values)
	
		if( equal( key, setting_key )){
			while( values[ 0 ] != 0 && strtok( values, key, charsmax( key ), values, charsmax( values ), ',')){
				trim( key );
				trim( values );
			
				ArrayPushCell( array_handle, str_to_float( key ))
			}
			
			fclose( file );
			return true;
		}
	}

	fclose(file)
	return false;
}

public LoadSettingString( const filename[], const setting_section[], setting_key[], return_string[], string_size){
	if (strlen(filename) < 1){
		//jail_log( LOG_ERROR, "Nao e possivel carregar as configuracoes: play_jailbreak.ini")
		return false;
	}

	if (strlen(setting_section) < 1 || strlen(setting_key) < 1){
		//jail_log( LOG_ERROR, "Nao e possivel carregar as configuracoes: empty section/key")
		return false;
	}
	
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, filename)
	
	if (!file_exists(path))
		return false;

	new file = fopen(path, "rt")
	if (!file)
		return false;

	new linedata[1024], section[64]
	while (!feof(file)){
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		
		if(linedata[0] == '['){
			copyc(section, charsmax(section), linedata[1], ']')
		
			if (equal(section, setting_section))
				break;
		}
	}
	
	if (!equal(section, setting_section)){
		fclose(file)
		return false;
	}
	
	new key[64], current_value[128]
	while (!feof(file)){
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		
		if (!linedata[0] || linedata[0] == ';')
			continue;
		
		if (linedata[0] == '[')
			break;
		
		strtok(linedata, key, charsmax(key), current_value, charsmax(current_value), '=')
		
		trim(key)
		trim(current_value)
		
		if (equal(key, setting_key)){
			/////// const
			formatex(return_string, string_size, "%s", current_value)
			fclose(file)
			return true;
			
			/* int
			if (equal(key, setting_key)){
				return_value = str_to_num(current_value)
				fclose(file)
				return return_value
			}
			*/
		}
	}
	
	fclose( file );
	return false;
}

public LoadSettingInt(const filename[], const setting_section[], setting_key[], return_value){
	if (strlen(filename) < 1){
		//jail_log( LOG_ERROR, "Nao e possivel carregar as configuracoes: play_jailbreak.ini")
		return false;
	}
	
	if (strlen(setting_section) < 1 || strlen(setting_key) < 1){
		//jail_log( LOG_ERROR, "Nao e possivel carregar as configuracoes: empty section/key")
		return false;
	}
	
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, filename)
	
	if (!file_exists(path))
		return false;
	
	new file = fopen(path, "rt")
	if (!file)
		return false;
	
	new linedata[1024], section[64]
	while (!feof(file)){
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")

		if (linedata[0] == '['){
			copyc(section, charsmax(section), linedata[1], ']')
			
			if (equal(section, setting_section))
				break;
		}
	}
	
	if (!equal(section, setting_section)){
		fclose(file)
		return false;
	}
	
	new key[64], current_value[32]
	while (!feof(file)){
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
	
		if (!linedata[0] || linedata[0] == ';')
			continue;
		
		if (linedata[0] == '[')
			break;
		
		strtok(linedata, key, charsmax(key), current_value, charsmax(current_value), '=')
		
		trim(key)
		trim(current_value)
		
		if (equal(key, setting_key)){
			return_value = str_to_num(current_value)
			fclose(file)
			return return_value
		}
	}

	fclose(file)
	return false;
}
