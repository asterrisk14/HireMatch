import 'package:flutter/material.dart';
import '../models/job_post.dart';

class JobCard extends StatelessWidget {
  final JobPost job;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [job.employmentTypeName, job.location]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A3535),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: job.companyLogoUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  job.companyLogoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _logoFallback(),
                ),
              )
                  : _logoFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onSaveToggle != null)
              IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? const Color(0xFFE74C3C) : Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: onSaveToggle,
              ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        job.title.isNotEmpty ? job.title.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(
          color: Color(0xFF0E7C7C),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}