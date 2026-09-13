package imgui.moulberry90.extension.texteditor.flag;

import imgui.moulberry90.binding.annotation.BindingAstEnum;
import imgui.moulberry90.binding.annotation.BindingSource;
import imgui.moulberry90.binding.annotation.ExcludedSource;

@ExcludedSource
@BindingSource
public final class TextEditorSelectionMode {
    private TextEditorSelectionMode() {
    }

    @BindingAstEnum(file = "ast-TextEditor.json", qualType = "TextEditor::SelectionMode")
    public Void __;
}
