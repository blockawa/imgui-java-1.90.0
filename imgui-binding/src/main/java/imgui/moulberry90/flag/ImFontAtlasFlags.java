package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImFontAtlas build
 */
@BindingSource
public final class ImFontAtlasFlags {
    private ImFontAtlasFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.moulberry90.json", qualType = "ImFontAtlasFlags_")
    public Void __;
}
