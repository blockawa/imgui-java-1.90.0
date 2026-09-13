package imgui.moulberry90.callback;

import imgui.moulberry90.ImGuiInputTextCallbackData;

import java.util.function.Consumer;

/**
 * Callback to use in {@link imgui.moulberry90.ImGui#inputText(String, imgui.moulberry90.type.ImString, int, ImGuiInputTextCallback)}.
 */
public abstract class ImGuiInputTextCallback implements Consumer<ImGuiInputTextCallbackData> {
    /**
     * This function will be called by the native Callback and wrapped.
     */
    public final void accept(final long ptr) {
        accept(new ImGuiInputTextCallbackData(ptr));
    }
}
