extends RefCounted

## 6.8 纹理别名表（B-03）。
## 路径以项目相对形式保存，避免被资源路径契约误判为丢失的 res:// 字面量；
## 原 6.8 路径用于兼容旧输入，当前 snake_case 路径只补齐当前缺失且目标存在的项，
## 不覆盖当前已恢复的同名资产。

const ALIASES: Dictionary = {
	"Art/HeroPicture/Role1/WuShuangHuoYanJinJingCropped/hyjj_ws_051.png":
	"Art/hero_picture/role_1/wu_shuang_huo_yan_jin_jing_cropped/hyjj_ws_050.png",
	"Art/HeroPicture/Role1/WuShuangHuoYanJinJingCropped/hyjj_ws_052.png":
	"Art/hero_picture/role_1/wu_shuang_huo_yan_jin_jing_cropped/hyjj_ws_050.png",
	"Art/HeroPicture/Role1/WuShuangHuoYanJinJingFull/hyjj_ws_051.png":
	"Art/hero_picture/role_1/wu_shuang_huo_yan_jin_jing_full/hyjj_ws_050.png",
	"Art/HeroPicture/Role1/WuShuangHuoYanJinJingFull/hyjj_ws_052.png":
	"Art/hero_picture/role_1/wu_shuang_huo_yan_jin_jing_full/hyjj_ws_050.png",
	"Art/HeroPicture/Role1AllEquipment/Role_1_Body_jczj.png":
	"Art/hero_picture/role_1_all_equipment/role_1_body_dsyj.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_014.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_013.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_016.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_015.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_017.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_015.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_020.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_019.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_022.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_021.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_023.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_021.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_026.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_025.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_028.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_027.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_029.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_027.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_032.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_031.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_034.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_033.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_035.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_033.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_038.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_037.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_041.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_040.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_044.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_043.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_046.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_045.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_047.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_045.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_050.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_049.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_052.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_051.png",
	"Art/HeroPicture/Role2/BingYu/spine/bingyu_053.png": "Art/hero_picture/role_2/bing_yu/spine/bingyu_051.png",
	"Art/HeroPicture/Role3/BaDiQianKunSmooth/bdqk_029.png":
	"Art/hero_picture/role_3/ba_di_qian_kun_smooth/bdqk_028.png",
	"Art/HeroPicture/Role3/BaDiQianKunSpine/bdqk_029.png": "Art/hero_picture/role_3/ba_di_qian_kun_spine/bdqk_028.png",
	"Art/HeroPicture/Role3/Role3Bullet2Stream/26.png": "Art/hero_picture/ttzssz_bullet_cropped/23.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_040.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_041.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_042.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_043.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_044.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_045.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_046.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_047.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_048.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_049.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_050.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_051.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_052.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_053.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_054.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_055.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_056.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_057.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/CangMuLongYun/frames/cmly_trim_058.png":
	"Art/hero_picture/role_4/cang_mu_long_yun/frames/cmly_trim_000.png",
	"Art/HeroPicture/Role4/SpecialEffet_10.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/HeroPicture/Role4/SpecialEffet_21.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/HeroPicture/Role4/SpecialEffet_8.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/HeroPicture/Role4AllEquipment/Role_4_Body_smsrsz.png":
	"Art/hero_picture/role_4_all_equipment/role_4_eq_smsrsz.png",
	"Art/HeroPicture/Role4AllEquipment/Role_4_Body_ssjdyhyf.png":
	"Art/hero_picture/role_4_all_equipment/role_4_body_empty.png",
	"Art/HeroPicture/Role4AllEquipment/Role_4_Eq_ssjdyhwq.png":
	"Art/hero_picture/role_4_all_equipment/role_4_eq_empty.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/formation_spine/formation_01.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/formation_spine/formation_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/formation_spine/formation_02.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/formation_spine/formation_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/formation_spine/formation_65.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/formation_spine/formation_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_35.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_36.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_37.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_38.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_39.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_40.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_41.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_42.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_43.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_44.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_45.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5/LeiTingJieZhen/lightning_spine/lightning_46.png":
	"Art/hero_picture/role_5/lei_ting_jie_zhen/lightning_spine/lightning_00.png",
	"Art/HeroPicture/Role5AllEquipment/Role_5_Body_bljdyhyf.png":
	"Art/hero_picture/role_5_all_equipment/role_5_body_ptcf.png",
	"Art/HeroPicture/Role5AllEquipment/Role_5_Eq_bljdyhwq.png":
	"Art/hero_picture/role_5_all_equipment/role_5_eq_pttq.png",
	"Art/HeroPicture/Wings/hhyq/10.png": "Art/hero_picture/wings/hhyq/9.png",
	"Art/HeroPicture/Wings/hhyq/11.png": "Art/hero_picture/wings/hhyq/9.png",
	"Art/HeroPicture/Wings/hhyq/12.png": "Art/hero_picture/wings/hhyq/9.png",
	"Art/HeroPicture/Wings/hhyq/14.png": "Art/hero_picture/wings/hhyq/13.png",
	"Art/HeroPicture/Wings/hhyq/15.png": "Art/hero_picture/wings/hhyq/13.png",
	"Art/HeroPicture/Wings/hhyq/16.png": "Art/hero_picture/wings/hhyq/13.png",
	"Art/HeroPicture/Wings/hhyq/18.png": "Art/hero_picture/wings/hhyq/17.png",
	"Art/HeroPicture/Wings/hhyq/19.png": "Art/hero_picture/wings/hhyq/17.png",
	"Art/HeroPicture/Wings/hhyq/2.png": "Art/hero_picture/wings/hhyq/1.png",
	"Art/HeroPicture/Wings/hhyq/20.png": "Art/hero_picture/wings/hhyq/17.png",
	"Art/HeroPicture/Wings/hhyq/22.png": "Art/hero_picture/wings/hhyq/21.png",
	"Art/HeroPicture/Wings/hhyq/23.png": "Art/hero_picture/wings/hhyq/21.png",
	"Art/HeroPicture/Wings/hhyq/24.png": "Art/hero_picture/wings/hhyq/21.png",
	"Art/HeroPicture/Wings/hhyq/26.png": "Art/hero_picture/wings/hhyq/25.png",
	"Art/HeroPicture/Wings/hhyq/27.png": "Art/hero_picture/wings/hhyq/25.png",
	"Art/HeroPicture/Wings/hhyq/28.png": "Art/hero_picture/wings/hhyq/25.png",
	"Art/HeroPicture/Wings/hhyq/3.png": "Art/hero_picture/wings/hhyq/1.png",
	"Art/HeroPicture/Wings/hhyq/30.png": "Art/hero_picture/wings/hhyq/29.png",
	"Art/HeroPicture/Wings/hhyq/31.png": "Art/hero_picture/wings/hhyq/29.png",
	"Art/HeroPicture/Wings/hhyq/32.png": "Art/hero_picture/wings/hhyq/29.png",
	"Art/HeroPicture/Wings/hhyq/34.png": "Art/hero_picture/wings/hhyq/33.png",
	"Art/HeroPicture/Wings/hhyq/35.png": "Art/hero_picture/wings/hhyq/33.png",
	"Art/HeroPicture/Wings/hhyq/36.png": "Art/hero_picture/wings/hhyq/33.png",
	"Art/HeroPicture/Wings/hhyq/38.png": "Art/hero_picture/wings/hhyq/37.png",
	"Art/HeroPicture/Wings/hhyq/39.png": "Art/hero_picture/wings/hhyq/37.png",
	"Art/HeroPicture/Wings/hhyq/4.png": "Art/hero_picture/wings/hhyq/1.png",
	"Art/HeroPicture/Wings/hhyq/40.png": "Art/hero_picture/wings/hhyq/37.png",
	"Art/HeroPicture/Wings/hhyq/6.png": "Art/hero_picture/wings/hhyq/5.png",
	"Art/HeroPicture/Wings/hhyq/7.png": "Art/hero_picture/wings/hhyq/5.png",
	"Art/HeroPicture/Wings/hhyq/8.png": "Art/hero_picture/wings/hhyq/5.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/100.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/42.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/43.png": "Art/magic_weapon/eight_immortal/dkhl/effect/39.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/44.png": "Art/magic_weapon/eight_immortal/dkhl/effect/38.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/45.png": "Art/magic_weapon/eight_immortal/dkhl/effect/37.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/46.png": "Art/magic_weapon/eight_immortal/dkhl/effect/36.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/47.png": "Art/magic_weapon/eight_immortal/dkhl/effect/35.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/48.png": "Art/magic_weapon/eight_immortal/dkhl/effect/34.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/49.png": "Art/magic_weapon/eight_immortal/dkhl/effect/33.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/50.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/51.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/52.png": "Art/magic_weapon/eight_immortal/dkhl/effect/33.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/53.png": "Art/magic_weapon/eight_immortal/dkhl/effect/34.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/54.png": "Art/magic_weapon/eight_immortal/dkhl/effect/35.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/55.png": "Art/magic_weapon/eight_immortal/dkhl/effect/36.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/56.png": "Art/magic_weapon/eight_immortal/dkhl/effect/37.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/57.png": "Art/magic_weapon/eight_immortal/dkhl/effect/38.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/58.png": "Art/magic_weapon/eight_immortal/dkhl/effect/39.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/59.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/60.png": "Art/magic_weapon/eight_immortal/dkhl/effect/41.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/61.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/62.png": "Art/magic_weapon/eight_immortal/dkhl/effect/39.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/63.png": "Art/magic_weapon/eight_immortal/dkhl/effect/38.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/64.png": "Art/magic_weapon/eight_immortal/dkhl/effect/37.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/65.png": "Art/magic_weapon/eight_immortal/dkhl/effect/36.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/66.png": "Art/magic_weapon/eight_immortal/dkhl/effect/35.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/67.png": "Art/magic_weapon/eight_immortal/dkhl/effect/34.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/68.png": "Art/magic_weapon/eight_immortal/dkhl/effect/33.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/69.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/70.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/71.png": "Art/magic_weapon/eight_immortal/dkhl/effect/33.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/72.png": "Art/magic_weapon/eight_immortal/dkhl/effect/34.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/73.png": "Art/magic_weapon/eight_immortal/dkhl/effect/35.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/74.png": "Art/magic_weapon/eight_immortal/dkhl/effect/36.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/75.png": "Art/magic_weapon/eight_immortal/dkhl/effect/37.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/76.png": "Art/magic_weapon/eight_immortal/dkhl/effect/38.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/77.png": "Art/magic_weapon/eight_immortal/dkhl/effect/39.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/78.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/79.png": "Art/magic_weapon/eight_immortal/dkhl/effect/41.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/80.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/81.png": "Art/magic_weapon/eight_immortal/dkhl/effect/39.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/82.png": "Art/magic_weapon/eight_immortal/dkhl/effect/38.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/83.png": "Art/magic_weapon/eight_immortal/dkhl/effect/37.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/84.png": "Art/magic_weapon/eight_immortal/dkhl/effect/36.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/85.png": "Art/magic_weapon/eight_immortal/dkhl/effect/35.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/86.png": "Art/magic_weapon/eight_immortal/dkhl/effect/34.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/87.png": "Art/magic_weapon/eight_immortal/dkhl/effect/33.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/88.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/89.png": "Art/magic_weapon/eight_immortal/dkhl/effect/32.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/90.png": "Art/magic_weapon/eight_immortal/dkhl/effect/33.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/91.png": "Art/magic_weapon/eight_immortal/dkhl/effect/34.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/92.png": "Art/magic_weapon/eight_immortal/dkhl/effect/35.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/93.png": "Art/magic_weapon/eight_immortal/dkhl/effect/36.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/94.png": "Art/magic_weapon/eight_immortal/dkhl/effect/37.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/95.png": "Art/magic_weapon/eight_immortal/dkhl/effect/38.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/96.png": "Art/magic_weapon/eight_immortal/dkhl/effect/39.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/97.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/98.png": "Art/magic_weapon/eight_immortal/dkhl/effect/41.png",
	"Art/MagicWeapon/EightImmortal/dkhl/effect/99.png": "Art/magic_weapon/eight_immortal/dkhl/effect/40.png",
	"Art/MagicWeapon/EightImmortal/hehua/effect/1.png": "Art/magic_weapon/eight_immortal/hehua/371_wplh.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/10.png": "Art/magic_weapon/eight_immortal/sxyg/effect/9.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/12.png": "Art/magic_weapon/eight_immortal/sxyg/effect/11.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/14.png": "Art/magic_weapon/eight_immortal/sxyg/effect/13.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/16.png": "Art/magic_weapon/eight_immortal/sxyg/effect/15.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/2.png": "Art/magic_weapon/eight_immortal/sxyg/effect/1.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/4.png": "Art/magic_weapon/eight_immortal/sxyg/effect/3.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/6.png": "Art/magic_weapon/eight_immortal/sxyg/effect/5.png",
	"Art/MagicWeapon/EightImmortal/sxyg/effect/8.png": "Art/magic_weapon/eight_immortal/sxyg/effect/7.png",
	"Art/MagicWeapon/EightImmortal/yyb/535_yyb.alpha.png": "Art/magic_weapon/eight_immortal/yyb/effect/1.png",
	"Art/MagicWeapon/EightImmortal/yyzlj/DefineSprite_729_SwordEffect.png":
	"Art/magic_weapon/eight_immortal/yyzlj/effect/1.png",
	"Art/MagicWeapon/GuanyinSummon/source/skeleton.png": "Art/monster/guanyin_spine/skeleton.png",
	"Art/MagicWeapon/MagicWeapon7/kyl.png": "Art/magic_weapon/kyl.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/10.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/11.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/12.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/14.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/15.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/16.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/18.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/19.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/2.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/20.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/3.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/4.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/6.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/7.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/field_frames/8.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/flash_frames/12.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/11.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/flash_frames/14.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/flash_frames/2.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/flash_frames/6.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/flash_frames/8.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/7.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/10.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/11.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/12.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/14.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/15.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/16.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/18.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/19.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/2.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/20.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/21.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/22.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/23.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/24.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/3.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/4.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/6.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/7.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/idle_frames/8.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/spawn_frames/2.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/spawn_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/spawn_frames/4.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/spawn_frames/3.png",
	"Art/MagicWeapon/MagicWeapon_DiKongYuMoQuan/spawn_frames/6.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/spawn_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/10.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/11.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/12.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/14.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/15.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/16.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/18.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/19.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/2.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/20.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/22.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/21.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/23.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/21.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/24.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/21.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/3.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/4.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/6.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/7.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_QingLian/idle_frames/8.png":
	"Art/magic_weapon/magic_weapon_qing_lian/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/10.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/12.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/11.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/14.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/16.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/15.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/18.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/20.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/19.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/22.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/21.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/24.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/23.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/26.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/25.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/28.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/27.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/3.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/2.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/5.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/4.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/7.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/6.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/effect_frames/8.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/6.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/flash_frames/12.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/11.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/flash_frames/13.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/flash_frames/14.png":
	"Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/flash_frames/2.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/flash_frames/6.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/flash_frames/8.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/7.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/10.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/11.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/12.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/9.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/14.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/15.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/16.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/13.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/18.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/19.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/2.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/20.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/17.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/21.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/22.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/23.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/24.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/3.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/4.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/1.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/6.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/7.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/MagicWeapon/MagicWeapon_ZhenLeiTianChui/idle_frames/8.png":
	"Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/5.png",
	"Art/Monster/Game3Monster/Monster_130/1.png": "Art/monster/monster_head/ce.png",
	"Art/Monster/Game3Monster/Monster_130/frames/death/1.png": "Art/monster/game_3_monster/monster_130/3.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit1/1.png": "Art/monster/game_3_monster/monster_130/4.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit2/1.png": "Art/monster/game_3_monster/monster_130/5.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit3/1.png": "Art/monster/game_3_monster/monster_130/6.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit4/1.png": "Art/monster/game_3_monster/monster_130/7.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hurt/1.png": "Art/monster/game_3_monster/monster_130/2.png",
	"Art/Monster/Game3Monster/Monster_130/frames/wait/1.png": "Art/monster/monster_head/ce.png",
	"Art/Monster/Game3Monster/Monster_163/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_163/body/4.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_164/body/4.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hit1/1.png": "Art/monster/game_3_monster/monster_164/body/5.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_164/body/6.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hit3/1.png": "Art/monster/game_3_monster/monster_164/body/7.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hurt/1.png": "Art/monster/game_3_monster/monster_164/body/3.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/wait/1.png": "Art/monster/game_3_monster/monster_164/body/1.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/walk/1.png": "Art/monster/game_3_monster/monster_164/body/2.png",
	"Art/Monster/Game3Monster/Monster_166/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_166/body/6.png",
	"Art/Monster/Game3Monster/Monster_168/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_168/body/6.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_174/body/4.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hit1/1.png": "Art/monster/game_3_monster/monster_174/body/5.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_174/body/6.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hit3/1.png": "Art/monster/game_3_monster/monster_174/body/7.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hurt/1.png": "Art/monster/game_3_monster/monster_174/body/3.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/wait/1.png": "Art/monster/game_3_monster/monster_174/body/1.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/walk/1.png": "Art/monster/game_3_monster/monster_174/body/2.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_175/body/15.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit1/1.png":
	"Art/monster/game_3_monster/monster_175/body/20.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit2/1.png":
	"Art/monster/game_3_monster/monster_175/body/25.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit3/1.png":
	"Art/monster/game_3_monster/monster_175/body/30.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hurt/1.png":
	"Art/monster/game_3_monster/monster_175/body/10.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/wait/1.png": "Art/monster/game_3_monster/monster_175/body/1.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/walk/1.png": "Art/monster/game_3_monster/monster_175/body/5.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/DefineSprite_236_Role1Bullet1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/DefineSprite_441_Role1Bullet14_2/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/DefineSprite_240_Role1Bullet5/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_2/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet5/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/1.png",
	"Art/Monster/SwfPng/3056/attack1/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/idle/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/walk/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/Tongtian3057/preview.png": "Art/monster/monster_head/ttjz.png",
	"Art/Mount/OfficialRiders/Role7/gear_1/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_11/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_15/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_17/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_2/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_23/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_24/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_26/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_28/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_3/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_33/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_35/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_36/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_4/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_5/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_6/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_7/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/OfficialRiders/Role7/gear_9/parts.png": "Art/hero_picture/role_7/official_parts/default/parts.png",
	"Art/Mount/Runtime/Effects/1002800/effect3_1/back_0.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
	"Art/magic_weapon/eight_immortal/yyb/535_yyb.alpha.png": "Art/magic_weapon/eight_immortal/yyb/effect/1.png",
	"Art/magic_weapon/guanyin_summon/source/skeleton.png": "Art/monster/guanyin_spine/skeleton.png",
	"Art/monster/game_3_monster/monster_130/frames/hit_1/1.png": "Art/monster/game_3_monster/monster_130/4.png",
	"Art/monster/game_3_monster/monster_130/frames/hit_2/1.png": "Art/monster/game_3_monster/monster_130/5.png",
	"Art/monster/game_3_monster/monster_130/frames/hit_3/1.png": "Art/monster/game_3_monster/monster_130/6.png",
	"Art/monster/game_3_monster/monster_130/frames/hit_4/1.png": "Art/monster/game_3_monster/monster_130/7.png",
	"Art/monster/game_3_monster/monster_164/body_actions/hit_1/1.png":
	"Art/monster/game_3_monster/monster_164/body/5.png",
	"Art/monster/game_3_monster/monster_164/body_actions/hit_2/1.png":
	"Art/monster/game_3_monster/monster_164/body/6.png",
	"Art/monster/game_3_monster/monster_164/body_actions/hit_3/1.png":
	"Art/monster/game_3_monster/monster_164/body/7.png",
	"Art/monster/game_3_monster/monster_166/body_actions/hit_2/1.png":
	"Art/monster/game_3_monster/monster_166/body/6.png",
	"Art/monster/game_3_monster/monster_168/body_actions/hit_2/1.png":
	"Art/monster/game_3_monster/monster_168/body/6.png",
	"Art/monster/game_3_monster/monster_174/body_actions/hit_1/1.png":
	"Art/monster/game_3_monster/monster_174/body/5.png",
	"Art/monster/game_3_monster/monster_174/body_actions/hit_2/1.png":
	"Art/monster/game_3_monster/monster_174/body/6.png",
	"Art/monster/game_3_monster/monster_174/body_actions/hit_3/1.png":
	"Art/monster/game_3_monster/monster_174/body/7.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_1/1.png":
	"Art/monster/game_3_monster/monster_175/body/20.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_2/1.png":
	"Art/monster/game_3_monster/monster_175/body/25.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_3/1.png":
	"Art/monster/game_3_monster/monster_175/body/30.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/define_sprite_236_role_1_bullet_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/define_sprite_441_role_1_bullet_14_2/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/define_sprite_240_role_1_bullet_5/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/1.png",
	"Art/monster/swf_png/3056/attack_1/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/mount/runtime/effects/1002800/effect_3_1/back_0.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
}

static var _hit_counts: Dictionary = {}
static var _hit_dir: String = ""
static var _hit_dir_checked: bool = false


static func _hit_capture_dir() -> String:
	if not _hit_dir_checked:
		_hit_dir_checked = true
		if OS.is_debug_build():
			_hit_dir = OS.get_environment("BHYH_TEXTURE_ALIAS_HITS_DIR").strip_edges()
	return _hit_dir


static func _record_hit(key: String) -> void:
	if _hit_capture_dir().is_empty():
		return
	_hit_counts[key] = int(_hit_counts.get(key, 0)) + 1


## 每个进程退出时由 Global._exit_tree 调用；按 PID 写独立 JSON，避免并发追加冲突。
static func flush_hit_stats() -> void:
	var directory := _hit_capture_dir()
	if directory.is_empty() or _hit_counts.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory.path_join("alias_hits_%d.json" % OS.get_process_id())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_hit_counts))
	file.close()
	_hit_counts.clear()


static func resolve(path: String) -> String:
	var key := path.trim_prefix("res://")
	var resolved: Variant = ALIASES.get(key)
	if resolved == null:
		return "res://" + key
	_record_hit(key)
	return "res://" + str(resolved)
