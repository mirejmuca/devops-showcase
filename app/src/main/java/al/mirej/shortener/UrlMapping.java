package al.mirej.shortener;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "url_mapping")
public class UrlMapping {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 16)
    private String code;

    @Column(nullable = false, length = 2048)
    private String targetUrl;

    private Instant createdAt = Instant.now();

    protected UrlMapping() {}

    public UrlMapping(String code, String targetUrl) {
        this.code = code;
        this.targetUrl = targetUrl;
    }

    public String getCode() { return code; }
    public String getTargetUrl() { return targetUrl; }
}