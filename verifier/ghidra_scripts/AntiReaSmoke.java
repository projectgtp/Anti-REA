import ghidra.app.script.GhidraScript;
import ghidra.program.model.data.StringDataType;
import ghidra.program.model.listing.Data;
import ghidra.program.model.listing.DataIterator;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;
import java.util.ArrayList;
import java.util.List;

/**
 * Anti-REA Ghidra smoke post-script (L90). Run by
 * verifier/ghidra_smoke.py via analyzeHeadless -postScript.
 * Counts functions and defined strings containing the needle
 * (script arg 0). Prints ANTIREA-SMOKE lines the Python driver
 * parses. No writes, no network, no side effects.
 */
public class AntiReaSmoke extends GhidraScript {
    @Override
    protected void run() throws Exception {
        String needle = getScriptArgs().length > 0 ? getScriptArgs()[0] : "";
        int fns = 0;
        List<String> names = new ArrayList<>();
        FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
        while (it.hasNext()) {
            Function f = it.next();
            fns++;
            names.add(f.getName());
        }
        int strHits = 0;
        int definedStrings = 0;
        DataIterator di = currentProgram.getListing().getDefinedData(true);
        while (di.hasNext()) {
            Data d = di.next();
            Object v = d.getValue();
            if (v instanceof String || d.getDataType() instanceof StringDataType) {
                definedStrings++;
                String s = String.valueOf(v);
                if (!needle.isEmpty() && s.contains(needle)) {
                    strHits++;
                }
            }
        }
        println("ANTIREA-SMOKE functions=" + fns);
        println("ANTIREA-SMOKE function_names=" + names);
        println("ANTIREA-SMOKE defined_strings=" + definedStrings);
        println("ANTIREA-SMOKE needle=" + needle + " string_hits=" + strHits);
    }
}
