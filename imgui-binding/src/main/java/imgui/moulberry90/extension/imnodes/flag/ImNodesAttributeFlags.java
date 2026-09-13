package imgui.moulberry90.extension.imnodes.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * This enum controls the way the attribute pins behave.
 */
@BindingSource
public final class ImNodesAttributeFlags {
    private ImNodesAttributeFlags() {
    }

    @BindingAstEnum(file = "ast-imnodes.json", qualType = "ImNodesAttributeFlags_")
    public Void __;
}
