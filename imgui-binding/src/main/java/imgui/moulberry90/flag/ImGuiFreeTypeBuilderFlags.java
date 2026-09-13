package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public final class ImGuiFreeTypeBuilderFlags {
    private ImGuiFreeTypeBuilderFlags() {
    }

    @BindingAstEnum(file = "ast-imgui_freetype.json", qualType = "ImGuiFreeTypeBuilderFlags", sanitizeName = "ImGuiFreeTypeBuilderFlags_")
    public Void __;
}
