#if defined _play_registro_included
  #endinput
#endif
#define _play_registro_included

#pragma reqlib play_registro

//forward registro_user_autenticou( index, PrimeiraVez);

forward registro_user_autenticou( index );

native bool:is_user_steam( index );
native registro_user_liberado( index );

//native get_user_login( index, const string[], len );
//native get_user_email( index, const string[], len );
//native get_user_password( index, const string[], len );

native get_user_key( index, const string[], len );

/** USAR APENAS PARA NO-STEAM OU PLAYERS QUE NAO SE REGISTRAM **/
//native get_user_rid( id );