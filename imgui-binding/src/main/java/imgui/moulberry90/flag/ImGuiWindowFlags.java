package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImGui::Begin()
 */
@BindingSource
public final class ImGuiWindowFlags {
    private ImGuiWindowFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiWindowFlags_")
    public Void __;
}
