---=====================================
---东方梦摇篮 debug功能控制
---THLoOP Debug Function Control
---=====================================

---以下功能为本游戏的debug功能，开启后不保证游戏稳定运行
---true为开启，false为关闭
---请不要改动true和false以外的字符，否则可能导致游戏报错

_debug = {
    _debug = true, --启用debug功能，该项为false则将下列项全部视为false
    debug_tool = false, --F1键开启修改器，可以修改资源数量、秒杀boss等
    imgui = true, --F3键开启imgui debug工具，包含多项调试功能
    hana_ai = false, --F7键开启HanaAI自动避弹（注：此项是否开启不影响LSC最终阶段的自机自动避弹）
    cheat = true, --F12键开启无敌
    collicheck = true, --~键开启判定显示
    skip_opening = true, --跳过开场加载界面（也可按ESC键跳过）
    skip_loading = true, --跳过转场加载界面（也可按S键跳过）
    bgm_debug = false, --bgm名debug，显示所有bgm名
    music_room_debug = false, --音乐室debug，显示相关信息
    full_window_title = false, --显示完整窗口标题信息（包括FPS，Obj数信息）
    exception_handler_disabled = true, --关闭全局异常捕获，方便debug
    l10n_tryexcept_disabled = true, --关闭l10n加载文件时的异常捕获
}
