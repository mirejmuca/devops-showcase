package al.mirej.shortener;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

@RestController
public class ShortenerController {

    public record ShortenRequest(
            @NotBlank
            @Pattern(regexp = "^https?://.+", message = "must start with http:// or https://")
            String url) {}

    public record ShortenResponse(String code, String shortUrl) {}

    private final ShortenerService service;

    public ShortenerController(ShortenerService service) {
        this.service = service;
    }

    @PostMapping("/shorten")
    public ResponseEntity<ShortenResponse> shorten(@Valid @RequestBody ShortenRequest request) {
        UrlMapping mapping = service.shorten(request.url());
        String shortUrl = "http://localhost:8080/" + mapping.getCode();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ShortenResponse(mapping.getCode(), shortUrl));
    }

    @GetMapping("/{code:[a-zA-Z0-9]{7}}")
    public ResponseEntity<Void> redirect(@PathVariable String code) {
        return service.find(code)
                .map(m -> ResponseEntity.status(HttpStatus.FOUND)
                        .header(HttpHeaders.LOCATION, URI.create(m.getTargetUrl()).toString())
                        .<Void>build())
                .orElse(ResponseEntity.notFound().build());
    }
}