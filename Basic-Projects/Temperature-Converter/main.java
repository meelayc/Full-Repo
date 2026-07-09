import javax.swing.SwingUtilities;

public class main {

    public static void main(String[] args) {
        //Launch projects as visible, with no relative location
        SwingUtilities.invokeLater(() -> {
            ConverterGUI gui = new ConverterGUI();

            gui.setVisible(true);

            gui.setLocationRelativeTo(null);
        });

    }
}
