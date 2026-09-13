package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for {@link imgui.moulberry90.ImGui#tableNextRow(int)}
 */
@BindingSource
public final class ImGuiTableRowFlags {
    private ImGuiTableRowFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.moulberry90.json", qualType = "ImGuiTableRowFlags_")
    public Void __;
}
