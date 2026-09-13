package imgui.moulberry90.extension.imguizmo.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public final class Mode {
    private Mode() {
    }

    @BindingAstEnum(file = "ast-ImGuizmo.json", qualType = "ImGuizmo::MODE")
    public Void __;
}
