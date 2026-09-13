package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImGui::DockSpace(), shared/inherited by child nodes.
 * (Some flags can be applied to individual nodes directly)
 */
@BindingSource
public final class ImGuiDockNodeFlags {
    private ImGuiDockNodeFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiDockNodeFlags_")
    public Void __;
}
