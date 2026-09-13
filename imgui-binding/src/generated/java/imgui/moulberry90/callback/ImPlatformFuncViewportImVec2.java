package imgui.moulberry90.callback;

import imgui.moulberry90.ImGuiViewport;
import imgui.moulberry90.ImVec2;

/**
 * Callback to represent ImGuiPlatformIO function with args: (ImGuiViewport*, ImVec2)
 */
public abstract class ImPlatformFuncViewportImVec2 {
    public abstract void accept(ImGuiViewport vp, ImVec2 imVec2);
}
