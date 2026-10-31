package al.mirej.shortener;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UrlMappingRepository extends JpaRepository<UrlMapping, Long> {
    Optional<UrlMapping> findByCode(String code);
    boolean existsByCode(String code);
}