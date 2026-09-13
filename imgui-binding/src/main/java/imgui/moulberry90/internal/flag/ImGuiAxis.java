package imgui.moulberry90.internal.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public final class ImGuiAxis {
    private ImGuiAxis() {
    }

    @BindingAstEnum(file = "ast-imgui_internal.json", qualType = "ImGuiAxis", sanitizeName = "ImGuiAxis_")
    public Void __;
}
