package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * A cardinal direction
 */
@BindingSource
public final class ImGuiDir {
    private ImGuiDir() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiDir", sanitizeName = "ImGuiDir_")
    public Void __;
}
