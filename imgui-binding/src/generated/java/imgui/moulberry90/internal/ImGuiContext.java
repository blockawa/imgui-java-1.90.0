package imgui.moulberry90.internal;

import imgui.moulberry90.binding.ImGuiStruct;

public class ImGuiContext extends ImGuiStruct {
    public ImGuiContext(final long ptr) {
        super(ptr);
        ImGui.init();
    }
}
