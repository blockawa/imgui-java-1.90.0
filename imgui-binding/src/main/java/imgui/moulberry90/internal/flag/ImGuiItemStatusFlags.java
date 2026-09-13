package imgui.moulberry90.internal.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public class ImGuiItemStatusFlags {
    private ImGuiItemStatusFlags() {
    }

    @BindingAstEnum(file = "ast-imgui_internal.json", qualType = "ImGuiItemStatusFlags_")
    public Void __;
}
