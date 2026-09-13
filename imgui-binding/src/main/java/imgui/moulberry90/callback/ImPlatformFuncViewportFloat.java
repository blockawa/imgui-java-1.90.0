package imgui.moulberry90.callback;

import imgui.moulberry90.ImGuiViewport;

/**
 * Callback to represent ImGuiPlatformIO function with args: (ImGuiViewport*, String)
 */
public abstract class ImPlatformFuncViewportFloat {
    public abstract void accept(ImGuiViewport vp, float f);
}
