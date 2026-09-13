package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImDrawList functions
 */
@BindingSource
public final class ImDrawFlags {
    private ImDrawFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImDrawFlags_")
    public Void __;
}
