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
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet1/10.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_1/9.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet1/11.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_1/9.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet1/12.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_1/9.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet1/13.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_1/9.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet1/14.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_1/9.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet1/15.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_1/9.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/23.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/24.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/25.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/26.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/27.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/28.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/29.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet2/30.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_2/22.png",
	"Art/Monster/Game3Monster/Monster_119/Monster119Bullet3/15.png":
	"Art/monster/game_3_monster/monster_119/monster_119_bullet_3/14.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/12.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/13.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/14.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/15.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/16.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/17.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/18.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/19.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/2.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/1.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/20.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/21.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/11.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/4.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/3.png",
	"Art/Monster/Game3Monster/Monster_120/Monster120Bullet2/8.png":
	"Art/monster/game_3_monster/monster_120/monster_120_bullet_2/7.png",
	"Art/Monster/Game3Monster/Monster_130/1.png": "Art/monster/monster_head/ce.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/16.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/17.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/18.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/19.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/20.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/21.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/22.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/23.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/24.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/25.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/26.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/27.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/28.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/29.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet3/30.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_3/15.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/10.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/9.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/12.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/11.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/14.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/13.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/2.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/1.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/4.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/3.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/6.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/5.png",
	"Art/Monster/Game3Monster/Monster_130/effects/Monster130Bullet4/8.png":
	"Art/monster/game_3_monster/monster_130/effects/monster_130_bullet_4/7.png",
	"Art/Monster/Game3Monster/Monster_130/frames/death/1.png": "Art/monster/game_3_monster/monster_130/3.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit1/1.png": "Art/monster/game_3_monster/monster_130/4.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit2/1.png": "Art/monster/game_3_monster/monster_130/5.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit3/1.png": "Art/monster/game_3_monster/monster_130/6.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hit4/1.png": "Art/monster/game_3_monster/monster_130/7.png",
	"Art/Monster/Game3Monster/Monster_130/frames/hurt/1.png": "Art/monster/game_3_monster/monster_130/2.png",
	"Art/Monster/Game3Monster/Monster_130/frames/wait/1.png": "Art/monster/monster_head/ce.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/18.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/19.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/20.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/21.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/22.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/23.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/24.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/25.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet2/26.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_2/17.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/10.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/1.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/11.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/1.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/14.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/13.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/15.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/13.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/16.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/7.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/17.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/7.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/2.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/1.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/3.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/1.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/5.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/4.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/6.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/4.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/8.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/7.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet3/9.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_3/7.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/11.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/12.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/13.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/14.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/15.png": "Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/2.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_4/1.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/3.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_4/1.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/5.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_4/4.png",
	"Art/Monster/Game3Monster/Monster_148/Monster148Bullet4/6.png":
	"Art/monster/game_3_monster/monster_148/monster_148_bullet_4/4.png",
	"Art/Monster/Game3Monster/Monster_163/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_163/body/4.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_164/body/4.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hit1/1.png": "Art/monster/game_3_monster/monster_164/body/5.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_164/body/6.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hit3/1.png": "Art/monster/game_3_monster/monster_164/body/7.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/hurt/1.png": "Art/monster/game_3_monster/monster_164/body/3.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/wait/1.png": "Art/monster/game_3_monster/monster_164/body/1.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/wait/5.png":
	"Art/monster/game_3_monster/monster_164/body_actions/wait/2.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/wait/6.png": "Art/monster/game_3_monster/monster_164/body/1.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/walk/1.png": "Art/monster/game_3_monster/monster_164/body/2.png",
	"Art/Monster/Game3Monster/Monster_164/body_actions/walk/4.png":
	"Art/monster/game_3_monster/monster_164/body_actions/walk/2.png",
	"Art/Monster/Game3Monster/Monster_166/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_166/body/6.png",
	"Art/Monster/Game3Monster/Monster_168/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_168/body/6.png",
	"Art/Monster/Game3Monster/Monster_168/body_actions/wait/5.png":
	"Art/monster/game_3_monster/monster_168/body_actions/wait/2.png",
	"Art/Monster/Game3Monster/Monster_168/body_actions/wait/6.png":
	"Art/monster/game_3_monster/monster_168/body_actions/wait/1.png",
	"Art/Monster/Game3Monster/Monster_168/body_actions/walk/4.png":
	"Art/monster/game_3_monster/monster_168/body_actions/walk/2.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_174/body/4.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hit1/1.png": "Art/monster/game_3_monster/monster_174/body/5.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hit2/1.png": "Art/monster/game_3_monster/monster_174/body/6.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hit3/1.png": "Art/monster/game_3_monster/monster_174/body/7.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/hurt/1.png": "Art/monster/game_3_monster/monster_174/body/3.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/wait/1.png": "Art/monster/game_3_monster/monster_174/body/1.png",
	"Art/Monster/Game3Monster/Monster_174/body_actions/walk/1.png": "Art/monster/game_3_monster/monster_174/body/2.png",
	"Art/Monster/Game3Monster/Monster_175/body/11.png": "Art/monster/game_3_monster/monster_175/body/10.png",
	"Art/Monster/Game3Monster/Monster_175/body/12.png": "Art/monster/game_3_monster/monster_175/body/10.png",
	"Art/Monster/Game3Monster/Monster_175/body/13.png": "Art/monster/game_3_monster/monster_175/body/10.png",
	"Art/Monster/Game3Monster/Monster_175/body/14.png": "Art/monster/game_3_monster/monster_175/body/10.png",
	"Art/Monster/Game3Monster/Monster_175/body/23.png": "Art/monster/game_3_monster/monster_175/body/20.png",
	"Art/Monster/Game3Monster/Monster_175/body/24.png": "Art/monster/game_3_monster/monster_175/body/21.png",
	"Art/Monster/Game3Monster/Monster_175/body/27.png": "Art/monster/game_3_monster/monster_175/body/25.png",
	"Art/Monster/Game3Monster/Monster_175/body/28.png": "Art/monster/game_3_monster/monster_175/body/26.png",
	"Art/Monster/Game3Monster/Monster_175/body/29.png": "Art/monster/game_3_monster/monster_175/body/25.png",
	"Art/Monster/Game3Monster/Monster_175/body/32.png": "Art/monster/game_3_monster/monster_175/body/30.png",
	"Art/Monster/Game3Monster/Monster_175/body/33.png": "Art/monster/game_3_monster/monster_175/body/31.png",
	"Art/Monster/Game3Monster/Monster_175/body/34.png": "Art/monster/game_3_monster/monster_175/body/30.png",
	"Art/Monster/Game3Monster/Monster_175/body/9.png": "Art/monster/game_3_monster/monster_175/body/5.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/death/1.png":
	"Art/monster/game_3_monster/monster_175/body/15.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/death/2.png":
	"Art/monster/game_3_monster/monster_175/body/16.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/death/3.png":
	"Art/monster/game_3_monster/monster_175/body/17.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/death/4.png":
	"Art/monster/game_3_monster/monster_175/body/18.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/death/5.png":
	"Art/monster/game_3_monster/monster_175/body/19.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit1/1.png":
	"Art/monster/game_3_monster/monster_175/body/20.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit1/2.png":
	"Art/monster/game_3_monster/monster_175/body/21.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit1/3.png":
	"Art/monster/game_3_monster/monster_175/body/22.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit2/1.png":
	"Art/monster/game_3_monster/monster_175/body/25.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit2/2.png":
	"Art/monster/game_3_monster/monster_175/body/26.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit3/1.png":
	"Art/monster/game_3_monster/monster_175/body/30.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hit3/2.png":
	"Art/monster/game_3_monster/monster_175/body/31.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/hurt/1.png":
	"Art/monster/game_3_monster/monster_175/body/10.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/wait/1.png": "Art/monster/game_3_monster/monster_175/body/1.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/wait/2.png": "Art/monster/game_3_monster/monster_175/body/2.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/wait/3.png": "Art/monster/game_3_monster/monster_175/body/3.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/wait/4.png": "Art/monster/game_3_monster/monster_175/body/4.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/walk/1.png": "Art/monster/game_3_monster/monster_175/body/5.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/walk/2.png": "Art/monster/game_3_monster/monster_175/body/6.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/walk/3.png": "Art/monster/game_3_monster/monster_175/body/7.png",
	"Art/Monster/Game3Monster/Monster_175/body_actions/walk/4.png": "Art/monster/game_3_monster/monster_175/body/8.png",
	"Art/Monster/Game3Monster/SwordBoss/luxian/atlas/atlas_04.png":
	"Art/monster/game_3_monster/sword_boss/luxian/atlas/atlas_03.png",
	"Art/Monster/Game3Monster/SwordBoss/luxian/atlas/atlas_05.png":
	"Art/monster/game_3_monster/sword_boss/luxian/atlas/atlas_03.png",
	"Art/Monster/Game3Monster/SwordBoss/zhuxian/atlas/atlas_10.png":
	"Art/monster/game_3_monster/sword_boss/zhuxian/atlas/atlas_09.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/11.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/10.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/12.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/10.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/14.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/13.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/15.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/13.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/17.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/16.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/18.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/16.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/2.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/1.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/20.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/19.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/21.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/19.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/23.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/22.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/24.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/22.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/26.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/25.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/27.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/25.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/3.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/1.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/5.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/4.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/6.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/4.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/8.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/7.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_guard/9.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_guard/7.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_line/11.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_line/10.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_line/13.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_line/12.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_line/15.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_line/14.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_line/17.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_line/16.png",
	"Art/Monster/Game3Monster/ThreePrince/jinzha/effect_line/9.png":
	"Art/monster/game_3_monster/three_prince/jinzha/effect_line/8.png",
	"Art/Monster/Game3Monster/ThreePrince/muzha/effect_aura/10.png":
	"Art/monster/game_3_monster/three_prince/muzha/effect_aura/9.png",
	"Art/Monster/Game3Monster/ThreePrince/muzha/effect_aura/2.png":
	"Art/monster/game_3_monster/three_prince/muzha/effect_aura/1.png",
	"Art/Monster/Game3Monster/ThreePrince/muzha/effect_aura/4.png":
	"Art/monster/game_3_monster/three_prince/muzha/effect_aura/3.png",
	"Art/Monster/Game3Monster/ThreePrince/muzha/effect_aura/6.png":
	"Art/monster/game_3_monster/three_prince/muzha/effect_aura/5.png",
	"Art/Monster/Game3Monster/ThreePrince/muzha/effect_aura/8.png":
	"Art/monster/game_3_monster/three_prince/muzha/effect_aura/7.png",
	"Art/Monster/Game3_SpecialEffect/Monster_4/atlas/Monster103Bullet1/pages/blank.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
	"Art/Monster/Game3_SpecialEffect/Monster_5/atlas/Monster114Bullet3/pages/blank.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
	"Art/Monster/Game3_SpecialEffect/Monster_7/Foursz/SpecialEffect_1.png":
	"Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3_SpecialEffect/Monster_7/Foursz/SpecialEffect_2.png":
	"Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/Game3_SpecialEffect/Monster_7/Foursz/SpecialEffect_3.png":
	"Art/hero_picture/role_4/special_effet_6.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet1/16.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet1/17.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet1/18.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet1/19.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet1/20.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet2/2.png": "Art/monster/hun_dun/effects/monster_60_bullet_2/1.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet2/3.png": "Art/monster/hun_dun/effects/monster_60_bullet_2/1.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet2/5.png": "Art/monster/hun_dun/effects/monster_60_bullet_2/4.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet2/6.png": "Art/monster/hun_dun/effects/monster_60_bullet_2/4.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/25.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/26.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/27.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/28.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/29.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/30.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/31.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/32.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/33.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/34.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/35.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/36.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/37.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/38.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/39.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Effects/Monster60Bullet3/40.png": "Art/monster/hun_dun/effects/monster_60_bullet_3/24.png",
	"Art/Monster/HunDun/Monster60Frames/12.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/14.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/15.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/16.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/17.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/18.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/23.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/24.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/29.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/30.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/33.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/34.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/35.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/36.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/37.png": "Art/monster/hun_dun/monster_60_frames/1.png",
	"Art/Monster/HunDun/Monster60Frames/40.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/41.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/42.png": "Art/monster/hun_dun/monster_60_frames/11.png",
	"Art/Monster/HunDun/Monster60Frames/6.png": "Art/monster/hun_dun/monster_60_frames/2.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/12.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/14.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/15.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/16.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/17.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/18.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/23.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/24.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/29.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/30.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/33.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/34.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/35.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/36.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/37.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/1.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/40.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/41.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/42.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/11.png",
	"Art/Monster/HunDun/Monster60FramesCenteredCropped/6.png":
	"Art/monster/hun_dun/monster_60_frames_centered_cropped/2.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet1/7.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_1/4.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet1/8.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_1/5.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet1/9.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_1/6.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet2/7.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_2/4.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet2/8.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_2/5.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet2/9.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_2/6.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet3/7.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_3/4.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet3/8.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_3/5.png",
	"Art/Monster/LiuShaRiver/Effects/Monster172Bullet3/9.png":
	"Art/monster/liu_sha_river/effects/monster_172_bullet_3/6.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/2.png": "Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/4.png": "Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/DefineSprite_236_Role1Bullet1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/DefineSprite_236_Role1Bullet1/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/DefineSprite_236_Role1Bullet1/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet1/DefineSprite_236_Role1Bullet1/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/10.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/10.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/11.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/11.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/12.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/12.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/13.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/13.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/14.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/14.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/15.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/15.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/2.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/4.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/5.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/6.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/6.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/7.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/7.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/8.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/8.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_1/DefineSprite_437_Role1Bullet14_1/9.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/9.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/DefineSprite_441_Role1Bullet14_2/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/DefineSprite_441_Role1Bullet14_2/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/DefineSprite_441_Role1Bullet14_2/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/DefineSprite_441_Role1Bullet14_2/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet14_2/DefineSprite_441_Role1Bullet14_2/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/2.png": "Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/4.png": "Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/DefineSprite_240_Role1Bullet5/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/DefineSprite_240_Role1Bullet5/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/DefineSprite_240_Role1Bullet5/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet5/DefineSprite_240_Role1Bullet5/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/1.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/10.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/10.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/2.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/3.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/4.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/5.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/6.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/6.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/7.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/7.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/8.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/8.png",
	"Art/Monster/LiuShaRiver/Effects/Role1Bullet8/DefineSprite_274_Role1Bullet8/9.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Monster172/Monster172Bullet1/17.png":
	"Art/monster/liu_sha_river/original_effects/monster_172/monster_172_bullet_1/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Monster172/Monster172Bullet1/18.png":
	"Art/monster/liu_sha_river/original_effects/monster_172/monster_172_bullet_1/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Monster172/Monster172Bullet1/19.png":
	"Art/monster/liu_sha_river/original_effects/monster_172/monster_172_bullet_1/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Monster172/Monster172Bullet1/20.png":
	"Art/monster/liu_sha_river/original_effects/monster_172/monster_172_bullet_1/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet1/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet1/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet1/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/10.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/12.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/14.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/16.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/18.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/17.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/2.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/20.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/22.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/21.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/24.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/23.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/26.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/25.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/28.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/27.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/30.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/29.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/32.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/31.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/34.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/33.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/36.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/35.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/38.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/37.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/4.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/40.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/39.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/42.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/41.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/44.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/43.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/6.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_2/8.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_2/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_4/10.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_4/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_4/2.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_4/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_4/4.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_4/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_4/6.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_4/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet10_4/8.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_10_4/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/10.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/12.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/14.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/16.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/18.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/17.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/2.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/20.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/21.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/22.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/23.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/24.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/25.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/26.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/27.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/28.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/29.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/30.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/31.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/32.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/33.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/34.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/35.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/4.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/6.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_1/8.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_1/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/10.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/12.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/14.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/16.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/18.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/17.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/2.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/20.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/21.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/22.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/23.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/24.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/25.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/26.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/27.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/28.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/29.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/30.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/31.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/32.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/33.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/34.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/35.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/4.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/6.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet11_2/8.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_11_2/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet12_1_2/10.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_12_1_2/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet12_1_2/15.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_12_1_2/14.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet12_1_2/5.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_12_1_2/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/20.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/21.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/22.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/23.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/24.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/25.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/26.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/27.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/28.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/29.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet13/30.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_13/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/10.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/11.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/12.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/12.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/13.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/14.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/14.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/15.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/6.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/7.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/8.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_1/9.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_2/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_2/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_2/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_2/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet14_2/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet5/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet5/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet5/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet5/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/11.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/12.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/14.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/15.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/2.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/3.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/5.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/6.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/8.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet7/9.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_7/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/10.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/6.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/7.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/8.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet8/9.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet9/10.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_9/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet9/2.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_9/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet9/4.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_9/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet9/6.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_9/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role1/Role1Bullet9/8.png":
	"Art/monster/liu_sha_river/original_effects/role_1/role_1_bullet_9/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet3/2.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_3/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet3/3.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_3/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet3/4.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_3/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet3/45.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_3/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet3/8.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_3/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/20.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/21.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/23.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/24.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/25.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/26.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/27.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/28.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/29.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/30.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/31.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/32.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/12.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/33.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/34.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/14.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/35.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/36.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/37.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/17.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/38.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/18.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/39.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/40.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/41.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/42.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/43.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/44.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/45.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/46.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/47.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet4_1/48.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_4_1/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/100.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/101.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/102.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/103.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/104.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/105.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/106.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/107.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/108.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/109.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/11.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/110.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/111.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/112.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/113.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/114.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/115.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/116.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/117.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/118.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/119.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/12.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/120.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/121.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/122.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/123.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/124.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/125.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/126.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/127.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/128.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/129.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/13.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/130.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/131.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/132.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/133.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/134.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/135.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/136.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/137.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/138.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/139.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/14.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/140.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/141.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/142.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/143.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/144.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/145.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/146.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/147.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/148.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/149.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/15.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/150.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/151.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/152.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/153.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/154.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/155.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/156.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/157.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/158.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/159.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/16.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/160.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/161.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/162.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/163.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/164.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/165.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/166.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/167.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/168.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/169.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/17.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/170.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/171.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/172.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/173.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/174.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/175.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/176.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/177.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/178.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/179.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/18.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/180.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/19.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/20.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/21.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/23.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/24.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/25.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/26.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/27.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/28.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/29.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/30.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/31.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/32.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/33.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/34.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/35.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/36.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/37.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/38.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/39.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/40.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/41.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/42.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/43.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/44.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/45.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/46.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/47.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/48.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/49.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/50.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/51.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/52.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/53.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/54.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/55.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/56.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/57.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/58.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/59.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/60.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/61.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/62.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/63.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/64.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/65.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/66.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/67.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/68.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/69.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/70.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/71.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/72.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/73.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/74.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/75.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/76.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/77.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/78.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/79.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/80.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/81.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/82.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/83.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/84.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/85.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/86.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/87.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/88.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/89.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/90.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/91.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/92.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/93.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/94.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/95.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/96.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/97.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/98.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet5/99.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_5/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/10.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/12.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/14.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/16.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/18.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/17.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/2.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/20.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/21.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/24.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/23.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/26.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/25.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/4.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/6.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet6/8.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_6/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/17.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/18.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/19.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/20.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/21.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/23.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/24.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/25.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/26.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet7/27.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_7/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/11.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/13.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/12.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/15.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/14.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/17.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/20.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/21.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/25.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/24.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/28.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/27.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/31.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/30.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/33.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/32.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/34.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/32.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet8/9.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_8/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/10.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/11.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/12.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/13.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/14.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/15.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/16.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/17.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/18.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/19.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/20.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/21.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/23.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/24.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/25.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/26.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/27.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/28.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/29.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/30.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/31.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/32.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/33.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/34.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/35.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/36.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/37.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/38.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/39.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/40.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/41.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/42.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/43.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/44.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/45.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/46.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/47.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/48.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/49.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/50.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/51.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/52.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/53.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/54.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/55.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/56.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_1/57.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_1/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/21.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/22.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/23.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/24.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/25.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/5.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/26.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/6.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/27.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/7.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/28.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/8.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/29.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/9.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/30.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/10.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/31.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/11.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/32.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/12.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/33.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/13.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/34.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/14.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/35.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/15.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/36.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/16.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/37.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/17.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/38.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/18.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/39.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/19.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/40.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/20.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/41.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/1.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/42.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/2.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/43.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/3.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/44.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/4.png",
	"Art/Monster/LiuShaRiver/OriginalEffects/Role2/Role2Bullet9_2/45.png":
	"Art/monster/liu_sha_river/original_effects/role_2/role_2_bullet_9_2/5.png",
	"Art/Monster/LiuShaRiver/Shadow2/walk/4.png": "Art/monster/liu_sha_river/shadow_2/walk/2.png",
	"Art/Monster/MonsterHead/weiyang3007.png": "Art/monster/swf_png/3007/preview.png",
	"Art/Monster/MonsterHead/通天教主(穷奇版).png": "Art/monster/swf_png/3117/preview.png",
	"Art/Monster/Monster_18/Bullet/atlas/Monster18Bullet_2/pages/blank.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
	"Art/Monster/Monster_20/Bullet/Bullet_2.png": "Art/monster/monster_20/bullet_2.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/2.png": "Art/monster/monster_33_34/bullet/chase_bullet/1.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/4.png": "Art/monster/monster_33_34/bullet/chase_bullet/3.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/6.png": "Art/monster/monster_33_34/bullet/chase_bullet/5.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/10.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/7.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/12.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/11.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/13.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/11.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/14.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/11.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/16.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/15.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/17.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/15.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/18.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/15.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/2.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/1.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/3.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/1.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/5.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/4.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/6.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/4.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/8.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/7.png",
	"Art/Monster/Monster_33_34/Bullet/chaseBullet/Boom/9.png":
	"Art/monster/monster_33_34/bullet/chase_bullet/boom/7.png",
	"Art/Monster/Monster_41/Bullet/2.png": "Art/monster/monster_41/bullet/1.png",
	"Art/Monster/Monster_41/Bullet/4.png": "Art/monster/monster_41/bullet/3.png",
	"Art/Monster/Monster_61-00/SP.png": "Art/monster/monster_66_1/sp.png",
	"Art/Monster/Monster_61-00/Skill1.png": "Art/monster/monster_66_1/skill1.png",
	"Art/Monster/Monster_61/atlas/Monster61Bullet3/pages/blank.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
	"Art/Monster/Monster_65/atlas/pages/blank.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
	"Art/Monster/NorthOriginal/3383/pages/atlas_000.png": "Art/monster/north_original/3382/pages/atlas_000.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_006.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_005.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_007.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_005.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_008.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_005.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_010.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_009.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_015.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_014.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_016.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_014.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_023.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_022.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_029.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_028.png",
	"Art/Monster/PetTigerBoss/atlas/pages/atlas_031.png": "Art/monster/pet_tiger_boss/atlas/pages/atlas_030.png",
	"Art/Monster/QiongQi/atlas/pages/atlas_006.png": "Art/monster/qiong_qi/atlas/pages/atlas_005.png",
	"Art/Monster/SwfPng/3056/attack1/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/attack1/10.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/attack1/11.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/attack1/12.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/attack1/13.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/attack1/14.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/attack1/15.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/attack1/16.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/attack1/17.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/attack1/18.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/attack1/19.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/attack1/2.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/attack1/20.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/attack1/21.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/attack1/22.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/attack1/23.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/attack1/24.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/attack1/25.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/attack1/26.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/attack1/27.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/attack1/28.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/attack1/29.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/attack1/3.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/attack1/30.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/attack1/31.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/attack1/32.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/attack1/4.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/attack1/5.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3056/attack1/6.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3056/attack1/7.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3056/attack1/8.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3056/attack1/9.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/idle/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/walk/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/walk/10.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/walk/11.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/walk/12.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/Monster/SwfPng/3056/walk/14.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/walk/15.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/walk/16.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/Monster/SwfPng/3056/walk/18.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/walk/19.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/walk/2.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/walk/20.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/Monster/SwfPng/3056/walk/22.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/walk/23.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/walk/24.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/Monster/SwfPng/3056/walk/26.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/walk/27.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/walk/28.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/Monster/SwfPng/3056/walk/3.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/walk/30.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/walk/31.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/walk/32.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/Monster/SwfPng/3056/walk/4.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/Monster/SwfPng/3056/walk/6.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3056/walk/7.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3056/walk/8.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/Monster/SwfPng/3077/death/10.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/2.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/3.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/4.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/5.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/6.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/7.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/8.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/death/9.png": "Art/monster/swf_png/3077/death/1.png",
	"Art/Monster/SwfPng/3077/skill1/10.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3077/skill1/11.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3077/skill1/12.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3077/skill1/13.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3077/skill1/14.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3077/skill1/15.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3077/skill1/22.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3077/skill1/23.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3077/skill1/24.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3077/skill1/25.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3077/skill1/26.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3077/skill1/27.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3077/tornado/11.png": "Art/monster/swf_png/3077/tornado/10.png",
	"Art/Monster/SwfPng/3077/tornado/12.png": "Art/monster/swf_png/3077/tornado/10.png",
	"Art/Monster/SwfPng/3077/tornado/17.png": "Art/monster/swf_png/3077/tornado/16.png",
	"Art/Monster/SwfPng/3077/tornado/18.png": "Art/monster/swf_png/3077/tornado/16.png",
	"Art/Monster/SwfPng/3077/tornado/5.png": "Art/monster/swf_png/3077/tornado/4.png",
	"Art/Monster/SwfPng/3077/tornado/6.png": "Art/monster/swf_png/3077/tornado/4.png",
	"Art/Monster/SwfPng/3080/attack/2.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3080/attack/3.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/Monster/SwfPng/3080/attack/5.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3080/attack/6.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/Monster/SwfPng/3080/attack/8.png": "Art/monster/swf_png/3080/attack/7.png",
	"Art/Monster/SwfPng/3080/attack/9.png": "Art/monster/swf_png/3080/attack/7.png",
	"Art/Monster/SwfPng/3081/attack/11.png": "Art/monster/swf_png/3081/attack/10.png",
	"Art/Monster/SwfPng/3081/attack/12.png": "Art/monster/swf_png/3081/attack/10.png",
	"Art/Monster/SwfPng/3081/attack/14.png": "Art/monster/swf_png/3081/attack/13.png",
	"Art/Monster/SwfPng/3081/attack/15.png": "Art/monster/swf_png/3081/attack/13.png",
	"Art/Monster/SwfPng/3081/attack/2.png": "Art/monster/swf_png/3081/attack/1.png",
	"Art/Monster/SwfPng/3081/attack/3.png": "Art/monster/swf_png/3081/attack/1.png",
	"Art/Monster/SwfPng/3081/attack/5.png": "Art/monster/swf_png/3081/attack/4.png",
	"Art/Monster/SwfPng/3081/attack/6.png": "Art/monster/swf_png/3081/attack/4.png",
	"Art/Monster/SwfPng/3081/attack/8.png": "Art/monster/swf_png/3081/attack/7.png",
	"Art/Monster/SwfPng/3081/attack/9.png": "Art/monster/swf_png/3081/attack/7.png",
	"Art/Monster/SwfPng/3082/wall/10.png": "Art/monster/swf_png/3082/wall/9.png",
	"Art/Monster/SwfPng/3082/wall/11.png": "Art/monster/swf_png/3082/wall/1.png",
	"Art/Monster/SwfPng/3082/wall/12.png": "Art/monster/swf_png/3082/wall/1.png",
	"Art/Monster/SwfPng/3082/wall/13.png": "Art/monster/swf_png/3082/wall/3.png",
	"Art/Monster/SwfPng/3082/wall/14.png": "Art/monster/swf_png/3082/wall/3.png",
	"Art/Monster/SwfPng/3082/wall/15.png": "Art/monster/swf_png/3082/wall/5.png",
	"Art/Monster/SwfPng/3082/wall/2.png": "Art/monster/swf_png/3082/wall/1.png",
	"Art/Monster/SwfPng/3082/wall/4.png": "Art/monster/swf_png/3082/wall/3.png",
	"Art/Monster/SwfPng/3082/wall/6.png": "Art/monster/swf_png/3082/wall/5.png",
	"Art/Monster/SwfPng/3082/wall/8.png": "Art/monster/swf_png/3082/wall/7.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet1/15.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet1/16.png": "Art/monster/hun_dun/effects/monster_60_bullet_1/15.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet2/10.png": "Art/monster/tao_tie/effects/monster_115_bullet_2/9.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet2/12.png": "Art/monster/tao_tie/effects/monster_115_bullet_2/11.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet2/2.png": "Art/monster/tao_tie/effects/monster_115_bullet_2/1.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet2/4.png": "Art/monster/tao_tie/effects/monster_115_bullet_2/3.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet2/6.png": "Art/monster/tao_tie/effects/monster_115_bullet_2/5.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet2/8.png": "Art/monster/tao_tie/effects/monster_115_bullet_2/7.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/11.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/12.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/13.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/14.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/15.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/16.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/17.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/10.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/18.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/6.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/19.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/3.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/20.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/1.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/22.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/23.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/24.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/25.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/26.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/27.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/28.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/29.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/30.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/31.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/32.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/33.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/34.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/35.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/36.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/37.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/38.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/39.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Effects/Monster115Bullet3/40.png": "Art/monster/tao_tie/effects/monster_115_bullet_3/21.png",
	"Art/Monster/TaoTie/Monster115Frames/10.png": "Art/monster/tao_tie/monster_115_frames/8.png",
	"Art/Monster/TaoTie/Monster115Frames/12.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/14.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/15.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/16.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/17.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/18.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/24.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/29.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/30.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/33.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/34.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/35.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/36.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/40.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/41.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/42.png": "Art/monster/tao_tie/monster_115_frames/11.png",
	"Art/Monster/TaoTie/Monster115Frames/5.png": "Art/monster/tao_tie/monster_115_frames/3.png",
	"Art/Monster/TaoTie/Monster115Frames/6.png": "Art/monster/tao_tie/monster_115_frames/2.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/10.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/8.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/12.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/14.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/15.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/16.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/17.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/18.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/24.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/29.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/30.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/33.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/34.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/35.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/36.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/40.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/41.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/42.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/11.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/5.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/3.png",
	"Art/Monster/TaoTie/Monster115FramesCenteredCropped/6.png":
	"Art/monster/tao_tie/monster_115_frames_centered_cropped/2.png",
	"Art/Monster/TaoWu/atlas/pages/atlas_007.png": "Art/monster/tao_wu/atlas/pages/atlas_006.png",
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
	"Art/monster/game_3_monster/monster_175/body_actions/hit_1/2.png":
	"Art/monster/game_3_monster/monster_175/body/21.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_1/3.png":
	"Art/monster/game_3_monster/monster_175/body/22.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_2/1.png":
	"Art/monster/game_3_monster/monster_175/body/25.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_2/2.png":
	"Art/monster/game_3_monster/monster_175/body/26.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_3/1.png":
	"Art/monster/game_3_monster/monster_175/body/30.png",
	"Art/monster/game_3_monster/monster_175/body_actions/hit_3/2.png":
	"Art/monster/game_3_monster/monster_175/body/31.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/define_sprite_236_role_1_bullet_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/define_sprite_236_role_1_bullet_1/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/define_sprite_236_role_1_bullet_1/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/define_sprite_236_role_1_bullet_1/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_1/3.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/10.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/10.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/11.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/11.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/12.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/12.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/13.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/13.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/14.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/14.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/15.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/15.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/2.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/3.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/4.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/5.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/6.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/6.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/7.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/7.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/8.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/8.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/define_sprite_437_role_1_bullet_14_1/9.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_1/9.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/define_sprite_441_role_1_bullet_14_2/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/define_sprite_441_role_1_bullet_14_2/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/define_sprite_441_role_1_bullet_14_2/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/define_sprite_441_role_1_bullet_14_2/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/define_sprite_441_role_1_bullet_14_2/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_14_2/4.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/define_sprite_240_role_1_bullet_5/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/define_sprite_240_role_1_bullet_5/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/define_sprite_240_role_1_bullet_5/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/define_sprite_240_role_1_bullet_5/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_5/3.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/1.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/1.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/10.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/10.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/2.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/2.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/3.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/3.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/4.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/4.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/5.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/5.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/6.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/6.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/7.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/7.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/8.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/8.png",
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/define_sprite_274_role_1_bullet_8/9.png":
	"Art/monster/liu_sha_river/effects/role_1_bullet_8/9.png",
	"Art/monster/monster_head/weiyang_3007.png": "Art/monster/swf_png/3007/preview.png",
	"Art/monster/monster_head/通天教主(穷奇版).png": "Art/monster/swf_png/3117/preview.png",
	"Art/monster/swf_png/3056/attack_1/1.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/monster/swf_png/3056/attack_1/10.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/monster/swf_png/3056/attack_1/11.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/monster/swf_png/3056/attack_1/12.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/monster/swf_png/3056/attack_1/13.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/monster/swf_png/3056/attack_1/14.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/monster/swf_png/3056/attack_1/15.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/monster/swf_png/3056/attack_1/16.png": "Art/monster/swf_png/3056/walk/13.png",
	"Art/monster/swf_png/3056/attack_1/17.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/monster/swf_png/3056/attack_1/18.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/monster/swf_png/3056/attack_1/19.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/monster/swf_png/3056/attack_1/2.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/monster/swf_png/3056/attack_1/20.png": "Art/monster/swf_png/3056/walk/17.png",
	"Art/monster/swf_png/3056/attack_1/21.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/monster/swf_png/3056/attack_1/22.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/monster/swf_png/3056/attack_1/23.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/monster/swf_png/3056/attack_1/24.png": "Art/monster/swf_png/3056/walk/21.png",
	"Art/monster/swf_png/3056/attack_1/25.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/monster/swf_png/3056/attack_1/26.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/monster/swf_png/3056/attack_1/27.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/monster/swf_png/3056/attack_1/28.png": "Art/monster/swf_png/3056/walk/25.png",
	"Art/monster/swf_png/3056/attack_1/29.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/monster/swf_png/3056/attack_1/3.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/monster/swf_png/3056/attack_1/30.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/monster/swf_png/3056/attack_1/31.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/monster/swf_png/3056/attack_1/32.png": "Art/monster/swf_png/3056/walk/29.png",
	"Art/monster/swf_png/3056/attack_1/4.png": "Art/monster/swf_png/3056/dead/1.png",
	"Art/monster/swf_png/3056/attack_1/5.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/monster/swf_png/3056/attack_1/6.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/monster/swf_png/3056/attack_1/7.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/monster/swf_png/3056/attack_1/8.png": "Art/monster/swf_png/3056/walk/5.png",
	"Art/monster/swf_png/3056/attack_1/9.png": "Art/monster/swf_png/3056/walk/9.png",
	"Art/monster/swf_png/3077/skill_1/10.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/monster/swf_png/3077/skill_1/11.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/monster/swf_png/3077/skill_1/12.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/monster/swf_png/3077/skill_1/13.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/monster/swf_png/3077/skill_1/14.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/monster/swf_png/3077/skill_1/15.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/monster/swf_png/3077/skill_1/22.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/monster/swf_png/3077/skill_1/23.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/monster/swf_png/3077/skill_1/24.png": "Art/monster/swf_png/3080/attack/1.png",
	"Art/monster/swf_png/3077/skill_1/25.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/monster/swf_png/3077/skill_1/26.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/monster/swf_png/3077/skill_1/27.png": "Art/monster/swf_png/3080/attack/4.png",
	"Art/mount/runtime/effects/1002800/effect_3_1/back_0.png":
	"Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/pages/blank.png",
}


static func resolve(path: String) -> String:
	var key := path.trim_prefix("res://")
	return "res://" + str(ALIASES.get(key, key))
