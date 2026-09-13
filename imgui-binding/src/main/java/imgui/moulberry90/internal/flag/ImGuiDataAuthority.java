package imgui.moulberry90.internal.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Store the source authority (dock node vs window) of a field
 */
@BindingSource
public final class ImGuiDataAuthority {
    private ImGuiDataAuthority() {
    }

    @BindingAstEnum(file = "ast-imgui_internal.json", qualType = "ImGuiDataAuthority_")
    public Void __;
}
