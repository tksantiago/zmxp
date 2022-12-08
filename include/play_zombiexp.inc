#if defined _zombiexp_included
  #endinput
#endif
#define _zombiexp_included


#define ACCES_VIP ADMIN_RESERVATION

/** EFEITO TRAIL DAS GRANADAS **/

/**
 * Retorna a quantidade de XP que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Quantidade de XP.
 */
native zmxp_get_user_xp(id)

/**
 * Força o salvamento de XP / Packs no banco.
 *
 * @param id		Player index.
 * @return		1.
 */
native zmxp_save_user(id)

/**
 * Retorna o level do upgrade 'Colete Anti-Infecção' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_armor(id)


/**
 * Retorna o level do upgrade 'Munição Automática' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_ammo(id)


/**
 * Retorna o level do upgrade 'Velocidade' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_speed(id)


/**
 * Retorna o level do upgrade 'Gravity' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_gravity(id)


/**
 * Retorna o level do upgrade 'Damage' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_damage(id)

/**
 * Retorna o level do upgrade 'Stamina' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_stamina(id)

/**
 * Retorna o level do upgrade 'HP' que a pessoa tem.
 *
 * @param id		Player index.
 * @return		Level do upgrade.
 */
native zmxp_get_user_hp(id)

/**
 * Da uma certa quantidade XP pra pessoa (não é necessário usar get_user_xp antes).
 *
 * @param id		Player index.
 * @params		Quantia de XP dada.
 */
native zmxp_set_user_xp(id, params)