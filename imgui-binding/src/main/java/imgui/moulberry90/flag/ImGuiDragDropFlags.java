package imgui.moulberry90.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;

/**
 * Flags for ImGui::BeginDragDropSource(), ImGui::AcceptDragDropPayload()
 */
@BindingSource
public final class ImGuiDragDropFlags {
    private ImGuiDragDropFlags() {
    }

    @BindingAstEnum(file = "ast-imgui.moulberry90.json", qualType = "ImGuiDragDropFlags_")
    public Void __;
}
