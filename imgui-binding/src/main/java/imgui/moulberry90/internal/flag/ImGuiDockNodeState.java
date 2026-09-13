package imgui.moulberry90.internal.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public final class ImGuiDockNodeState {
    private ImGuiDockNodeState() {
    }

    @BindingAstEnum(file = "ast-imgui_internal.json", qualType = "ImGuiDockNodeState", sanitizeName = "ImGuiDockNodeState_")
    public Void __;
}
