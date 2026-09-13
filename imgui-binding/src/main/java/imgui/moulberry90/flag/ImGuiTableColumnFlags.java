package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for {@link imgui.ImGui#tableSetupColumn(String, int)}
 */
@BindingSource
public final class ImGuiTableColumnFlags {
    private ImGuiTableColumnFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiTableColumnFlags_")
    public Void __;
}
