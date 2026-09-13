package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImGui::BeginCombo()
 */
@BindingSource
public final class ImGuiComboFlags {
    private ImGuiComboFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiComboFlags_")
    public Void __;
}
