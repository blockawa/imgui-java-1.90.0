package imgui.moulberry90.extension.imnodes.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * This enum controls the minimap's location.
 */
@BindingSource
public final class ImNodesMiniMapLocation {
    private ImNodesMiniMapLocation() {
    }

    @BindingAstEnum(file = "ast-imnodes.json", qualType = "ImNodesMiniMapLocation_")
    public Void __;
}
