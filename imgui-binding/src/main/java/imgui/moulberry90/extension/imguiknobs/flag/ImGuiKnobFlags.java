package imgui.moulberry90.extension.imguiknobs.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public final class ImGuiKnobFlags {
    private ImGuiKnobFlags() {
    }

    public static final int None = 0;

    @BindingAstEnum(file = "ast-imgui-knobs.json", qualType = "ImGuiKnobFlags_")
    public Void __;
}
