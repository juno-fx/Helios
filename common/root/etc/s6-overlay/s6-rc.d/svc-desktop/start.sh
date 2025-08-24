#!/usr/bin/env bash

# wait for X to be running
while true; do
  if xset q &>/dev/null; then
    break
  fi
  sleep .5
done

HOME="/home/$USER"

if [ -z "$USER" ]; then
	echo "No user configured"
	exit 1
fi

if [ -z "$UID" ]; then
	echo "No UID configured"
	exit 1
fi

if [ -z "$GID" ]; then
	echo "No GID configured, defaulting to matching UID"
	GID="$UID"
fi

# set the keyboard map by LC if known
if [ ! -z "${LC_ALL}" ]; then
  normalized_locale_full=${LC_ALL%%.*}
  normalized_locale_lower=$(echo "$normalized_locale_full" | tr '[:upper:]' '[:lower:]')

  declare -A LOCALE_TO_XKB_MAP=(
    ["af_za"]="za" ["am_et"]="et -variant am" ["ar_sa"]="sa" ["ar_eg"]="eg" ["ar"]="ara"
    ["as_in"]="in -variant asm" ["az_az"]="az -variant latin" ["be_by"]="by"
    ["ber_dz"]="dz -variant tifinagh" ["ber_ma"]="ma -variant tifinagh"
    ["bn_bd"]="bd -variant probhat" ["bn_in"]="in -variant ben" ["bo_cn"]="cn -variant tib"
    ["bo_in"]="in -variant tib" ["br_fr"]="fr -variant bre" ["brx_in"]="in -variant bod"
    ["bs_ba"]="ba" ["ca_es"]="es -variant cat" ["ca"]="es -variant cat" ["cs_cz"]="cz"
    ["cy_gb"]="gb -variant welsh" ["da_dk"]="dk" ["de_de"]="de" ["de_ch"]="ch -variant de"
    ["de_at"]="at" ["de_lu"]="lu" ["de_be"]="be" ["de"]="de" ["dv_mv"]="mv" ["dz_bt"]="bt"
    ["el_gr"]="gr" ["el_cy"]="cy" ["el"]="gr" ["en_us"]="us" ["en_gb"]="gb"
    ["en_ca"]="ca -variant eng" ["en_au"]="au" ["en_ie"]="ie" ["en_in"]="in -variant eng"
    ["en"]="us" ["es_es"]="es" ["es_mx"]="latam" ["es_ar"]="latam"
    ["es_us"]="us -variant intl" ["es"]="es" ["et_ee"]="ee" ["eu_es"]="eu" ["fa_ir"]="ir"
    ["fi_fi"]="fi" ["fo_fo"]="fo" ["fr_fr"]="fr" ["fr_ca"]="ca -variant fr" ["fr_be"]="be"
    ["fr_ch"]="ch -variant fr" ["fr_lu"]="lu" ["fr"]="fr" ["ga_ie"]="ie"
    ["gd_gb"]="gb -variant gd" ["gl_es"]="gl" ["gu_in"]="in -variant guj" ["he_il"]="il"
    ["hi_in"]="in -variant hin" ["hr_hr"]="hr" ["hsb_de"]="de -variant hsb" ["ht_ht"]="ht"
    ["hu_hu"]="hu" ["hy_am"]="am -variant eastern" ["id_id"]="id" ["is_is"]="is"
    ["it_it"]="it" ["it_ch"]="ch -variant it" ["it"]="it" ["ja_jp"]="jp" ["ka_ge"]="ge"
    ["kk_kz"]="kz" ["kl_gl"]="kl" ["km_kh"]="kh" ["kn_in"]="in -variant kan"
    ["kok_in"]="in -variant kok" ["ko_kr"]="kr" ["ks_in"]="in -variant kas_dev"
    ["ku_tr"]="tr -variant ku" ["ky_kg"]="kg" ["lb_lu"]="lu" ["lo_la"]="la" ["lt_lt"]="lt"
    ["lv_lv"]="lv" ["mai_in"]="in -variant mai" ["mg_mg"]="mg" ["mk_mk"]="mk"
    ["ml_in"]="in -variant mal" ["mni_in"]="in -variant mni_bengali" ["mn_mn"]="mn"
    ["mr_in"]="in -variant mar" ["ms_my"]="my" ["mt_mt"]="mt" ["my_mm"]="mm" ["nb_no"]="no"
    ["nn_no"]="no" ["no"]="no" ["ne_np"]="np" ["nl_nl"]="nl" ["nl_be"]="be" ["nl"]="nl"
    ["oc_fr"]="fr -variant oc" ["or_in"]="in -variant ori" ["pa_in"]="in -variant pan"
    ["pa_pk"]="pk -variant ur" ["pl_pl"]="pl" ["ps_af"]="ps" ["pt_pt"]="pt" ["pt_br"]="br"
    ["pt"]="pt" ["ro_ro"]="ro" ["ru_ru"]="ru" ["ru_ua"]="ua -variant ru" ["ru"]="ru"
    ["rw_rw"]="rw" ["sa_in"]="in -variant san_devanagari" ["sat_in"]="in -variant sat_olchiki"
    ["se_no"]="no -variant sme" ["si_lk"]="lk -variant sinhala_qwerty_us" ["sk_sk"]="sk"
    ["sl_si"]="si" ["so_so"]="so" ["sq_al"]="al" ["sq_mk"]="mk -variant sq" ["sr_rs"]="rs"
    ["sr_me"]="me" ["nr_za"]="za" ["nso_za"]="za" ["ss_za"]="za" ["st_za"]="za"
    ["tn_za"]="za" ["ts_za"]="za" ["ve_za"]="za" ["xh_za"]="za" ["zu_za"]="za"
    ["sv_se"]="se" ["sv_fi"]="fi -variant se" ["sv"]="se" ["ta_in"]="in -variant tam"
    ["ta_lk"]="lk -variant tam_unicode" ["te_in"]="in -variant tel" ["tg_tj"]="tj"
    ["th_th"]="th" ["ti_er"]="er" ["ti_et"]="et" ["tk_tm"]="tm -variant latn" ["tr_tr"]="tr"
    ["tr"]="tr" ["tt_ru"]="ru -variant tat" ["ug_cn"]="ug" ["uk_ua"]="ua"
    ["ur_in"]="in -variant urd" ["ur_pk"]="pk -variant ur" ["uz_uz"]="uz -variant latin"
    ["vi_vn"]="vn" ["yi_us"]="il" ["zh_cn"]="cn" ["zh_hk"]="hk" ["zh_sg"]="sg"
    ["zh_tw"]="tw" ["zh"]="cn"
  )

  if [[ -v "LOCALE_TO_XKB_MAP[$normalized_locale_lower]" ]]; then
    XKB_LAYOUT_ARGS="${LOCALE_TO_XKB_MAP[$normalized_locale_lower]}"
  fi
fi
if [ ! -z "$XKB_LAYOUT_ARGS" ]; then
  s6-setuidgid ${USER} setxkbmap ${XKB_LAYOUT_ARGS}
fi
chmod 777 /tmp/selkies*

# set sane resolution before starting apps
s6-setuidgid ${USER} xrandr --newmode "1024x768" 63.50  1024 1072 1176 1328  768 771 775 798 -hsync +vsync
s6-setuidgid ${USER} xrandr --addmode screen "1024x768"
s6-setuidgid ${USER} xrandr --output screen --mode "1024x768" --dpi 96

# set xresources
if [ -f "${HOME}/.Xresources" ]; then
  xrdb "${HOME}/.Xresources"
else
  echo "Xcursor.theme: breeze" > "${HOME}/.Xresources"
  xrdb "${HOME}/.Xresources"
fi
chown ${USER}:${USER} "${HOME}/.Xresources"

# run
cd $HOME
exec s6-setuidgid ${USER} \
  /bin/bash /opt/helios/startwm.sh &
