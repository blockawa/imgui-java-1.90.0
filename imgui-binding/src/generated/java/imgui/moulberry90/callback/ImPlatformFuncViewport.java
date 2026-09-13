package imgui.moulberry90.callback;

import imgui.moulberry90.ImGuiViewport;

/**
 * Callback to represent ImGuiPlatformIO function with args: (ImGuiViewport*)
 */
public abstract class ImPlatformFuncViewport {
    public abstract void accept(ImGuiViewport vp);
}
