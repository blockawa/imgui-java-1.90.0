package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * A sorting direction
 */
@BindingSource
public final class ImGuiSortDirection {
    private ImGuiSortDirection() {
    }

    @BindingAstEnum(file = "ast-imgui.moulberry90.json", qualType = "ImGuiSortDirection", sanitizeName = "ImGuiSortDirection_")
    public Void __;
}
