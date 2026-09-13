package imgui.moulberry90.extension.imnodes.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * This enum controls the way attribute pins look.
 */
@BindingSource
public final class ImNodesPinShape {
    private ImNodesPinShape() {
    }

    @BindingAstEnum(file = "ast-imnodes.json", qualType = "ImNodesPinShape_")
    public Void __;
}
