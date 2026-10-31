package al.mirej.shortener;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CodeGeneratorTest {
    private final CodeGenerator generator = new CodeGenerator();

    @Test
    void generatesRequestedLength() {
        assertEquals(7, generator.generate(7).length());
    }

    @Test
    void generatesOnlyAlphanumericCharacters() {
        assertTrue(generator.generate(50).matches("[a-zA-Z0-9]+"));
    }

    @Test
    void generatesDifferentCodes() {
        assertNotEquals(generator.generate(12), generator.generate(12));
    }
}