package al.mirej.shortener;

import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class ShortenerService {
    private final UrlMappingRepository repository;
    private final CodeGenerator generator;

    public ShortenerService(UrlMappingRepository repository, CodeGenerator generator) {
        this.repository = repository;
        this.generator = generator;
    }

    public UrlMapping shorten(String url) {
        String code;
        do {
            code = generator.generate(7);
        } while (repository.existsByCode(code));
        return repository.save(new UrlMapping(code, url));
    }

    public Optional<UrlMapping> find(String code) {
        return repository.findByCode(code);
    }
}