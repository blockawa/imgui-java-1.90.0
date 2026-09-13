package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImGui::BeginTabBar()
 */
@BindingSource
public final class ImGuiTabBarFlags {
    private ImGuiTabBarFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.json", qualType = "ImGuiTabBarFlags_")
    public Void __;
}
