package imgui.moulberry90.callback;

import imgui.moulberry90.ImGuiViewport;

/**
 * Callback to represent ImGuiPlatformIO function with args: (ImGuiViewport*) - Boolean
 */
public abstract class ImPlatformFuncViewportSuppBoolean {
    public abstract boolean get(ImGuiViewport vp);
}
