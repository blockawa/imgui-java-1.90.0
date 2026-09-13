package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

@BindingSource
public final class ImGuiSliderFlags {
    private ImGuiSliderFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiSliderFlags_")
    public Void __;
}
