package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * A primary data type
 */
@BindingSource
public final class ImGuiDataType {
    private ImGuiDataType() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiDataType_")
    public Void __;
}
